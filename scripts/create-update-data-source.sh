#!/bin/bash

# Load the API ID, Lambda Function ARN, and Role ARN from the YAML files
API_ID=$(yq e '.api_id' src/update-appsync.yml)
LAMBDA_FUNCTION_ARN=$(yq e '.lambda_function_arn' src/update-appsync.yml)
ROLE_ARN=$(yq e '.role_arn' src/update-appsync.yml)

# Check if Lambda function ARN and Role ARN are provided
if [ -z "$LAMBDA_FUNCTION_ARN" ] || [ -z "$ROLE_ARN" ]; then
  echo "Lambda Function ARN or Role ARN not found in update-appsync.yml. Please provide them."
  exit 1
fi

# Check if the data source exists
DATA_SOURCE_NAME="LambdaDataSource"

DATA_SOURCE_EXISTS=$(aws appsync list-data-sources --api-id $API_ID --query "dataSources[?name=='$DATA_SOURCE_NAME'] | length(@)")

if [ "$DATA_SOURCE_EXISTS" -eq "0" ]; then
  echo "Data source $DATA_SOURCE_NAME does not exist. Creating..."
  aws appsync create-data-source \
    --api-id $API_ID \
    --name $DATA_SOURCE_NAME \
    --description "Lambda data source" \
    --type AWS_LAMBDA \
    --lambda-config lambdaFunctionArn=$LAMBDA_FUNCTION_ARN \
    --service-role-arn $ROLE_ARN
else
  echo "Data source $DATA_SOURCE_NAME already exists. Updating..."
  aws appsync update-data-source \
    --api-id $API_ID \
    --name $DATA_SOURCE_NAME \
    --description "Lambda data source" \
    --type AWS_LAMBDA \
    --lambda-config lambdaFunctionArn=$LAMBDA_FUNCTION_ARN \
    --service-role-arn $ROLE_ARN
fi
