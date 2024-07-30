#!/bin/bash

# Fetch the API details from the Appsyncupdate.yml file
API_ID=$(yq e '.api_id' src/Appsyncupdate.yml)
API_NAME=$(yq e '.api_name' src/Appsyncupdate.yml)
AUTH_TYPE=$(yq e '.auth_type' src/Appsyncupdate.yml)
LAMBDA_AUTHORIZER_ARN=$(yq e '.lambda_authorizer_arn' src/Appsyncupdate.yml)

# Update GraphQL API with AWS Lambda authorization
aws appsync update-graphql-api \
  --api-id $API_ID \
  --name $API_NAME \
  --authentication-type $AUTH_TYPE \
  --lambda-authorizer-config authorizerUri="$LAMBDA_AUTHORIZER_ARN"
