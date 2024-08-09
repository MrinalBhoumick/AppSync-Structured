Here's a comprehensive README.md documentation for your setup:

---

# AWS AppSync CI/CD Setup

This repository contains a CI/CD pipeline setup for managing AWS AppSync GraphQL API components, including schemas, queries, mutations, and Lambda resolvers. The pipeline uses CodeBuild for automating the update and creation of these components based on changes pushed to the repository.

## Directory Structure

```
/root
  ├── buildspec.yml
  ├── Dockerfile
  ├── README.md
  ├── /src
  │    ├── /Queries
  │    │    ├── /Query1
  │    │    │    ├── request_mapping_template.yml
  │    │    │    └── response_mapping_template.yml
  │    │    ├── /Query2
  │    │    │    ├── request_mapping_template.yml
  │    │    │    └── response_mapping_template.yml
  │    │    └── ...
  │    ├── /Mutations
  │    │    ├── /Mutation1
  │    │    │    ├── request_mapping_template.yml
  │    │    │    └── response_mapping_template.yml
  │    │    ├── /Mutation2
  │    │    │    ├── request_mapping_template.yml
  │    │    │    └── response_mapping_template.yml
  │    │    └── ...
  │    ├── schema.graphql
  │    ├── update-appsync.yml
  │    ├── update-query.yml
  │    └── update-mutation.yml
  ├── /scripts
  │    ├── create-api.sh
  │    ├── create-update-data-source.sh
  │    ├── update-schema.sh
  │    ├── update-mapping-template.sh
  │    └── update-lambda-authorizer.sh
```

### File and Folder Descriptions

- **buildspec.yml**: The build specification file used by AWS CodeBuild to define the build steps.
- **Dockerfile**: Dockerfile used for creating a custom build environment.
- **README.md**: Documentation for the repository.
- **/src**: Contains the GraphQL schema, queries, and mutations, along with configuration files for updating the AppSync API.
  - **/Queries**: Directory containing subfolders for each query, with request and response mapping templates.
  - **/Mutations**: Directory containing subfolders for each mutation, with request and response mapping templates.
  - **schema.graphql**: The main GraphQL schema file for the AppSync API.
  - **update-appsync.yml**: Configuration file containing API-specific details such as API ID, region, and Lambda function ARN.
  - **update-query.yml**: List of queries to be updated or created.
  - **update-mutation.yml**: List of mutations to be updated or created.
- **/scripts**: Contains scripts for various tasks such as creating and updating the AppSync API, data sources, and resolvers.
  - **create-api.sh**: Script to create a new AppSync API.
  - **create-update-data-source.sh**: Script to create or update the data source for AppSync.
  - **update-schema.sh**: Script to update the AppSync schema.
  - **update-mapping-template.sh**: Script to update both request and response mapping templates for queries and mutations.
  - **update-lambda-authorizer.sh**: Script to update Lambda authorizers for AppSync.

## Setup and Usage

### Prerequisites

- AWS CLI installed and configured with necessary permissions.
- Docker installed (if using a custom Docker image).
- AWS AppSync API set up with necessary permissions.
- IAM roles configured for CodeBuild with permissions to access AppSync, Lambda, and other AWS services.

### 1. Clone the Repository

```bash
git clone https://github.com/your-repo/your-project.git
cd your-project
```

### 2. Update Configuration Files

Update the `SAM/update-appsync.yml` file with your API-specific details:

```yaml
api_id: your-appsync-api-id
lambda_function_arn: arn:aws:lambda:region:account-id:function:function-name
region: your-region
```

Update `SAM/update-query.yml` and `SAM/update-mutation.yml` with the queries and mutations you want to manage:

```yaml
queries:
  - Query1
  - Query2
mutations:
  - Mutation1
  - Mutation2
```

### 3. Create or Update AppSync API Components

The following scripts can be used to create or update your AppSync API components:

- **Create or Update API and Data Source**:

  ```bash
  ./scripts/create-api.sh
  ./scripts/create-update-data-source.sh
  ```

- **Update Schema**:

  ```bash
  ./scripts/update-schema.sh
  ```

- **Update Mapping Templates**:

  ```bash
  ./scripts/update-mapping-template.sh
  ```

- **Update Lambda Authorizers**:

  ```bash
  ./scripts/update-lambda-authorizer.sh
  ```

### 4. Automate with CI/CD

#### AWS CodeBuild

The `buildspec.yml` file defines the build steps for CodeBuild:

```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Pre-build phase...
      - mkdir -p artifacts
      - echo Checking for existing artifacts in S3...
      - |
        ARTIFACTS=$(aws s3 ls s3://$S3_BUCKET/ --recursive | grep 'last-successful-build.tar.gz' || echo "No previous build found in S3")
        if [ "$ARTIFACTS" != "No previous build found in S3" ]; then
          echo "Previous build artifact found. Downloading..."
          aws s3 cp s3://$S3_BUCKET/last-successful-build.tar.gz artifacts/last-successful-build.tar.gz
        fi

  build:
    commands:
      - echo Cloning the repository...
      - git clone https://github.com/MrinalBhoumick/AppSync-Structured.git /codebuild/repo
      - cd /codebuild/repo

      - echo Creating AppSync API if it does not exist...
      - bash scripts/create-api.sh || { echo "API creation failed"; touch rollback.flag; exit 1; }

      - echo Updating schema...
      - bash scripts/update-schema.sh || { echo "Schema update failed"; touch rollback.flag; exit 1; }

      - echo Creating or updating the data source...
      - bash scripts/create-update-data-source.sh || { echo "Data source update failed"; touch rollback.flag; exit 1; }

      - echo Updating mapping templates...
      - bash scripts/update-mapping-template.sh || { echo "Mapping update failed"; touch rollback.flag; exit 1; }

      - echo Updating Lambda authorizer...
      - bash scripts/update-lambda-authorizer.sh || { echo "Lambda authorizer update failed"; touch rollback.flag; exit 1; }

  post_build:
    commands:
      - echo Build phase completed. Checking for rollback flag...
      - |
        if [ -f rollback.flag ]; then
          echo "Build failed. Performing rollback..."
          # List all files in the S3 bucket
          ARTIFACTS=$(aws s3 ls s3://$S3_BUCKET/ --recursive | grep '.tar.gz' || echo "No artifacts found in S3")
          if [ "$ARTIFACTS" != "No artifacts found in S3" ]; then
            # Download the latest artifact from S3
            LATEST_ARTIFACT=$(echo "$ARTIFACTS" | sort | tail -n 1 | awk '{print $4}')
            echo "Found previous successful build artifact: $LATEST_ARTIFACT. Running rollback script..."
            aws s3 cp s3://$S3_BUCKET/$LATEST_ARTIFACT artifacts/latest-build.tar.gz
            chmod +x scripts/rollback.sh
            bash scripts/rollback.sh || { echo "Rollback failed"; exit 1; }
          else
            echo "No previous build artifact found in S3. Cannot perform rollback."
            exit 1
          fi
        else
          echo "Build succeeded. No rollback needed."
          echo Packaging the repository...
          mkdir -p artifacts
          tar --exclude='./artifacts' -czf artifacts/last-successful-build.tar.gz .
          echo Uploading package to S3...
          aws s3 cp artifacts/last-successful-build.tar.gz s3://$S3_BUCKET/last-successful-build.tar.gz || { echo "Upload to S3 failed"; exit 1; }
        fi

artifacts:
  files:
    - "**/*"

# Use the custom Docker image
image: 992382729083.dkr.ecr.ap-south-1.amazonaws.com/codebuild-custom-aml2023:latest

```

#### Custom Docker Image

The `Dockerfile` defines a custom build environment for CodeBuild:

```dockerfile
# Use Amazon Linux 2023 as the base image
FROM amazonlinux:2023

# Install necessary packages
RUN yum update -y && \
    yum install -y jq tar wget unzip git && \
    yum clean all

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/download/v4.14.2/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Define the entrypoint
ENTRYPOINT ["/bin/bash", "-c"]

```

### 5. Trigger a Build

Push changes to the repository to trigger the CI/CD pipeline. The pipeline will automatically run the `update-schema.sh` and `update-mapping-template.sh` scripts to apply any updates to the AppSync API.

### 6. Monitoring and Debugging

Monitor the build process through the AWS CodeBuild console. Any errors will be logged and can be reviewed for troubleshooting.

## Best Practices

- **Version Control**: Ensure that all changes to the GraphQL schema and mapping templates are committed to version control.
- **Automation**: Use CI/CD pipelines to automate the deployment process, reducing the risk of human error.
- **Environment Variables**: Store sensitive information and environment-specific details (e.g., API ID, region) as environment variables in CodeBuild or use secrets management services.

## Conclusion

This setup provides a structured approach to managing AWS AppSync APIs using CI/CD. By leveraging automation and version control, you can ensure that your API components are consistently deployed and updated with minimal manual intervention.

For further assistance or customization, refer to the AWS documentation or reach out to your DevOps team.

--- 

This documentation should guide users through the setup and usage of the CI/CD pipeline for AWS AppSync.