#!/bin/bash

# Fetch the API details from the Appsyncupdate.yaml file
API_ID=$(yq e '.api_id' src/Appsyncupdate.yaml)
API_NAME=$(yq e '.api_name' src/Appsyncupdate.yaml)
LAMBDA_AUTHORIZER_ARN=$(yq e '.lambda_authorizer_arn' src/Appsyncupdate.yaml)

# Update GraphQL API with AWS Lambda authorization
aws appsync update-graphql-api \
  --api-id $API_ID \
  --name $API_NAME \
  --authentication-type AWS_LAMBDA \
  --lambda-authorizer-config authorizerUri="$LAMBDA_AUTHORIZER_ARN"
