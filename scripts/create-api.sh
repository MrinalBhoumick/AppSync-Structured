#!/bin/bash

# Load API details from the YAML file
API_NAME=$(yq e '.api_name' src/update-appsync.yml)
LAMBDA_AUTHORIZER_ARN=$(yq e '.lambda_authorizer_arn' src/update-appsync.yml)

# Check if the API already exists
API_ID=$(aws appsync list-graphql-apis --query "graphqlApis[?name=='$API_NAME'].apiId | [0]" --output text)

if [ "$API_ID" == "None" ]; then
  echo "Creating new AppSync API with name: $API_NAME"

  # Create a new AppSync API
  API_ID=$(aws appsync create-graphql-api \
    --name $API_NAME \
    --authentication-type AWS_LAMBDA \
    --lambda-authorizer-config authorizerUri=$LAMBDA_AUTHORIZER_ARN \
    --query 'graphqlApi.apiId' --output text)
  
  echo "Created new AppSync API with ID: $API_ID"
  
  # Update the YAML file with the new API ID
  yq e -i ".api_id = \"$API_ID\"" src/update-appsync.yml
else
  echo "AppSync API already exists with ID: $API_ID"
fi
