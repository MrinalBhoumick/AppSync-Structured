#!/bin/bash

# Fetch the API details from the Appsyncupdatequeries.yml file
API_ID=$(yq e '.api_id' SAM/update-appsync.yml)
API_NAME=$(yq e '.api_name' SAM/update-appsync.yml)
LAMBDA_AUTHORIZER_ARN=$(yq e '.lambda_authorizer_arn' SAM/update-appsync.yml)

# Update GraphQL API with AWS Lambda authorization
aws appsync update-graphql-api \
  --api-id "$API_ID" \
  --name "$API_NAME" \
  --authentication-type AWS_LAMBDA \
  --lambda-authorizer-config authorizerUri="$LAMBDA_AUTHORIZER_ARN"
