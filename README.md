

# CI/CD Pipeline Setup

This repository contains the configuration and scripts to set up a CI/CD pipeline for deploying your application using GitHub Actions and AWS CodePipeline. The pipeline includes steps for building, testing, and deploying your application, as well as updating your AWS AppSync API.

## Prerequisites

Before you begin, ensure you have the following:

- AWS Account with appropriate permissions.
- Docker installed on your local machine.
- GitHub repository with your application code.
- AWS CLI configured with your credentials.
- Necessary AWS resources (e.g., AppSync API, S3 bucket, Lambda functions).

## Setup Instructions

### 1. AWS Setup

1. **Create IAM Role for GitHub Actions**:
   - Create an IAM role that GitHub Actions can assume. The role should have necessary permissions for accessing AWS resources (AppSync, S3, Lambda, etc.).

2. **ECR Repository**:
   - Ensure you have an ECR repository where your Docker image is stored.
   - Push your custom Docker image to the ECR repository.

3. **CodePipeline**:
   - Create a CodePipeline with appropriate stages and actions. Ensure the pipeline name matches the one used in the GitHub Actions workflow.

### 2. GitHub Repository Setup

1. **Clone Repository**:
   ```bash
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
   ```

2. **Add Secrets**:
   - Navigate to your GitHub repository settings.
   - Add the following secrets:
     - `XGITHUB_TOKEN`: GitHub token with repo and workflow permissions.
     - `S3_BUCKET`: Name of the S3 bucket.
     - `CODEPIPELINE_NAME`: Name of the CodePipeline.

3. **Add GitHub Actions Workflow**:
   - Create a `.github/workflows/ci-cd-pipeline.yml` file and add the following content:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    
    permissions:
      id-token: write
      contents: read
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up AWS credentials
        uses: aws-actions/configure-aws-credentials@v3
        with:
          aws-region: ap-south-1
          role-to-assume: arn:aws:iam::992382729083:role/GitHubActionsRole
          role-session-name: GitHubActionsSession
          audience: sts.amazonaws.com

      - name: Login to Amazon ECR
        uses: aws-actions/amazon-ecr-login@v1

      - name: Pull Docker image
        run: |
          docker pull 992382729083.dkr.ecr.ap-south-1.amazonaws.com/codebuild-custom-aml2023:latest

      - name: Run Docker container
        run: |
          docker run --rm -v ${{ github.workspace }}:/codebuild/repo -e S3_BUCKET=${{ secrets.S3_BUCKET }} 992382729083.dkr.ecr.ap-south-1.amazonaws.com/codebuild-custom-aml2023:latest /bin/bash -c "
            mkdir -p artifacts && \
            ARTIFACTS=$(aws s3 ls s3://$S3_BUCKET/ --recursive | grep 'last-successful-build.tar.gz' || echo 'No previous build found in S3') && \
            if [ \"$ARTIFACTS\" != \"No previous build found in S3\" ]; then \
              echo 'Previous build artifact found. Downloading...'; \
              aws s3 cp s3://$S3_BUCKET/last-successful-build.tar.gz artifacts/last-successful-build.tar.gz; \
            fi && \
            echo Creating AppSync API if it does not exist... && \
            bash scripts/create-api.sh || { echo 'API creation failed'; touch rollback.flag; exit 1; } && \
            echo Updating schema... && \
            bash scripts/update-schema.sh || { echo 'Schema update failed'; touch rollback.flag; exit 1; } && \
            echo Creating or updating the data source... && \
            bash scripts/create-update-data-source.sh || { echo 'Data source update failed'; touch rollback.flag; exit 1; } && \
            echo Updating request mapping templates... && \
            bash scripts/update-request-mapping-template.sh || { echo 'Request mapping update failed'; touch rollback.flag; exit 1; } && \
            echo Updating response mapping templates... && \
            bash scripts/update-response-mapping-template.sh || { echo 'Response mapping update failed'; touch rollback.flag; exit 1; } && \
            echo Updating Lambda authorizer... && \
            bash scripts/update-lambda-authorizer.sh || { echo 'Lambda authorizer update failed'; touch rollback.flag; exit 1; }"

      - name: Wait for CodePipeline to complete
        run: |
          sleep 45

      - name: Get latest CodePipeline execution ID
        id: get-execution-id
        run: |
          EXECUTION_ID=$(aws codepipeline list-pipeline-executions --pipeline-name ${{ secrets.CODEPIPELINE_NAME }} --query 'pipelineExecutionSummaries[0].pipelineExecutionId' --output text)
          echo "Pipeline execution ID: $EXECUTION_ID"
          echo "::set-output name=execution-id::$EXECUTION_ID"

      - name: Check CodePipeline status
        id: codepipeline-status
        run: |
          PIPELINE_STATUS=$(aws codepipeline get-pipeline-execution --pipeline-name ${{ secrets.CODEPIPELINE_NAME }} --pipeline-execution-id ${{ steps.get-execution-id.outputs.execution-id }} --query 'pipelineExecution.status' --output text)
          echo "Pipeline status: $PIPELINE_STATUS"
          echo "::set-output name=status::$PIPELINE_STATUS"

      - name: Post Build Status on Commit
        run: |
          if [ "${{ steps.codepipeline-status.outputs.status }}" == "Succeeded" ]; then
            curl -X POST \
              -H "Authorization: token ${{ secrets.XGITHUB_TOKEN }}" \
              -H "Accept: application/vnd.github.v3+json" \
              -d '{"body": "✅ Build succeeded"}' \
              "https://api.github.com/repos/${{ github.repository }}/commits/${{ github.sha }}/comments"
          else
            curl -X POST \
              -H "Authorization: token ${{ secrets.XGITHUB_TOKEN }}" \
              -H "Accept: application/vnd.github.v3+json" \
              -d '{"body": "❌ Build failed"}' \
              "https://api.github.com/repos/${{ github.repository }}/commits/${{ github.sha }}/comments"
          fi
        env:
          XGITHUB_TOKEN: ${{ secrets.XGITHUB_TOKEN }}

```

4. **Commit and Push Changes**:
   ```bash
   git add .
   git commit -m "Set up CI/CD pipeline"
   git push origin main
   ```

### 3. Workflow Breakdown

- **Checkout code**: Checks out the code from the repository.
- **Set up AWS credentials**: Configures AWS credentials for GitHub Actions.
- **Login to Amazon ECR**: Logs in to Amazon ECR to pull the Docker image.
- **Pull Docker image**: Pulls the custom Docker image from ECR.
- **Run Docker container**: Runs the Docker container and executes the build and deployment scripts.
- **Wait for CodePipeline Status**: Waits for 45 seconds and fetches the status of the CodePipeline execution.
- **Post Build Status**: Posts a comment on the commit with the build status.

## Notes

- Ensure all necessary AWS resources (AppSync API, Lambda functions, etc.) are properly set up and accessible.
- Customize the scripts in the Docker container as per your application's requirements.
- Monitor the pipeline and logs in GitHub Actions and AWS CodePipeline for troubleshooting.

## Troubleshooting

- **Pipeline Failures**: Check the logs in GitHub Actions and AWS CodePipeline for errors and resolve accordingly.
- **Permissions Issues**: Ensure the IAM roles and policies have the necessary permissions.
- **Docker Issues**: Verify that the Docker image and container are correctly configured and running.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss your changes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

Feel free to customize this README file based on your specific setup and requirements.