Here's a suggested structure for your project directory and a sample README file for managing your AWS AppSync API:

### Project Directory Structure

```
appsync-api-management/
│
├── src/
│   ├── Queries/
│   │   ├── Query1/
│   │   │   ├── request_mapping_template.graphql
│   │   │   └── response_mapping_template.graphql
│   │   ├── Query2/
│   │   │   ├── request_mapping_template.graphql
│   │   │   └── response_mapping_template.graphql
│   │   └── schema.graphql
│   ├── Mutations/
│   │   ├── Mutation1/
│   │   │   ├── request_mapping_template.graphql
│   │   │   └── response_mapping_template.graphql
│   │   ├── Mutation2/
│   │   │   ├── request_mapping_template.graphql
│   │   │   └── response_mapping_template.graphql
│   │   └── schema.graphql
│   ├── Appsyncupdatequeries.yml
│   └── Appsyncupdatemutations.yml
│
├── scripts/
│   ├── create-update-data-source.sh
│   ├── update-schema.sh
│   ├── update-resolvers.sh
│   └── create-api.sh
│
├── README.md
└── .gitignore
```

### README.md

```markdown
# AppSync API Management

This project provides scripts and configuration files to manage AWS AppSync APIs, including creating APIs, managing data sources, and updating resolvers and schemas.

## Project Structure

- **src/**: Contains GraphQL schema files, request and response mapping templates, and YAML configuration files.
  - **Queries/**: Contains subfolders for each query, with associated mapping templates.
  - **Mutations/**: Contains subfolders for each mutation, with associated mapping templates.
  - **Appsyncupdatequeries.yml**: YAML configuration file for updating queries.
  - **Appsyncupdatemutations.yml**: YAML configuration file for updating mutations.

- **scripts/**: Contains bash scripts for various AppSync API management tasks.
  - **create-update-data-source.sh**: Creates or updates the Lambda data source.
  - **update-schema.sh**: Updates the GraphQL schema for the API.
  - **update-resolvers.sh**: Updates resolvers for queries and mutations.
  - **create-api.sh**: Creates a new AppSync API if it does not already exist.

## Requirements

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) installed and configured.
- [yq](https://mikefarah.gitbook.io/yq/) installed for YAML file parsing.
- Proper AWS credentials and permissions to manage AppSync resources.

## Usage

1. **Create or Retrieve AppSync API**:
   ```bash
   bash scripts/create-api.sh
   ```

2. **Create or Update Lambda Data Source**:
   ```bash
   bash scripts/create-update-data-source.sh
   ```

3. **Update Resolvers for Queries and Mutations**:
   ```bash
   bash scripts/update-resolvers.sh
   ```

4. **Update Schema**:
   ```bash
   bash scripts/update-schema.sh
   ```

## Configuration

Edit the YAML files in the **src/** directory to provide API details, Lambda ARNs, and resolver information:

- **Appsyncupdatequeries.yml**: Configuration for queries.
- **Appsyncupdatemutations.yml**: Configuration for mutations.

## Troubleshooting

- Ensure that all required files are present in the **src/** directory.
- Verify that your AWS credentials are properly configured and have the necessary permissions.
- Check script outputs and logs for detailed error messages.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

### `.gitignore`

```gitignore
# Ignore YAML files with sensitive data
src/*.yml
src/Queries/**/request_mapping_template.graphql
src/Queries/**/response_mapping_template.graphql
src/Mutations/**/request_mapping_template.graphql
src/Mutations/**/response_mapping_template.graphql
```

## Build and Push the Docker Image to AWS ECR

**Create an ECR repository**:

aws ecr create-repository --repository-name codebuild-ami

**Authenticate Docker to your ECR registry**:

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com

**Build the Docker image**:

docker build -t codebuild-ami .

**Tag the Docker image**:

docker tag codebuild-ami:latest <account-id>.dkr.ecr.<your-region>.amazonaws.com/codebuild-custom-aml2023:latest


