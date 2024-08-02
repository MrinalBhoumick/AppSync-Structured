#!/bin/bash

# Load API details from the Appsyncupdatemutations.yml file
API_NAME=$(yq e '.api_name' src/Appsyncupdatemutations.yml)
AUTH_TYPE=$(yq e '.auth_type' src/Appsyncupdatemutations.yml)
LAMBDA_AUTHORIZER_ARN=$(yq e '.lambda_authorizer_arn' src/Appsyncupdatemutations.yml)

# Check if the API already exists
EXISTING_API_ID=$(aws appsync list-graphql-apis --query "graphqlApis[?name=='$API_NAME'].apiId" --output text)

if [ -z "$EXISTING_API_ID" ]; then
  echo "Creating new AppSync API: $API_NAME"
  
  # Create the new AppSync API
  CREATE_API_RESPONSE=$(aws appsync create-graphql-api \
    --name $API_NAME \
    --authentication-type $AUTH_TYPE \
    --lambda-authorizer-config authorizerUri=$LAMBDA_AUTHORIZER_ARN)

  # Extract the API ID
  API_ID=$(echo $CREATE_API_RESPONSE | jq -r '.graphqlApi.apiId')

  echo "AppSync API created with ID: $API_ID"

  # Save the API ID to the YAML files for future use
  yq e -i ".api_id = \"$API_ID\"" src/Appsyncupdatemutations.yml
  yq e -i ".api_id = \"$API_ID\"" src/Appsyncupdatequeries.yml
else
  echo "AppSync API $API_NAME already exists with ID: $EXISTING_API_ID"
  API_ID=$EXISTING_API_ID
fi

# Pass the API_ID as an environment variable for subsequent scripts
export API_ID