#!/bin/bash

set -x

# Load API details from the YAML file
API_ID=$(yq e '.api_id' SAM/update-appsync.yml)
API_NAME=$(yq e '.api_name' SAM/update-appsync.yml)

if [ "$API_ID" == "None" ] || [ -z "$API_ID" ]; then
  echo "API ID not found. Please ensure the API exists."
  exit 1
fi

if [ -z "$API_NAME" ]; then
  echo "API Name not found. Please ensure it is defined in the YAML file."
  exit 1
fi

# Base64 encode the schema file
SCHEMA_BASE64=$(base64 -w 0 src/schema.graphql)

# Update the schema in AppSync
echo "Starting schema creation..."
aws appsync start-schema-creation --api-id $API_ID --definition "$SCHEMA_BASE64"

# Poll the schema creation status until it's done
while true; do
  STATUS=$(aws appsync get-schema-creation-status --api-id $API_ID --query 'status' --output text)
  echo "Current schema creation status: $STATUS"
  if [ "$STATUS" == "SUCCESS" ]; then
    echo "Schema creation succeeded."
    break
  elif [ "$STATUS" == "FAILED" ]; then
    echo "Schema creation failed."
    touch rollback.flag
    aws appsync get-schema-creation-status --api-id $API_ID --query 'details' --output text
    exit 1
  else
    echo "Schema creation is still processing. Waiting for 10 seconds..."
    sleep 10
  fi
done
