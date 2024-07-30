#!/bin/bash

# Fetch the API details from the Appsyncupdate.yaml file
API_ID=$(yq e '.api_id' src/Appsyncupdate.yml)
SCHEMA_FILE="src/schema.graphql"

# Read and base64 encode the schema file content
SCHEMA_BASE64=$(base64 -w 0 < "$SCHEMA_FILE")

# Start schema creation with base64 encoded schema
response=$(aws appsync start-schema-creation \
  --api-id "$API_ID" \
  --definition "$SCHEMA_BASE64")

echo "Schema creation started: $response"

# Check status of schema creation
while true; do
  status=$(aws appsync get-schema-creation-status --api-id "$API_ID")
  echo "Current schema creation status: $(echo $status | jq -r '.status')"
  
  if [[ "$(echo $status | jq -r '.status')" == "SUCCESS" ]]; then
    echo "Schema creation successful."
    break
  elif [[ "$(echo $status | jq -r '.status')" == "FAILED" ]]; then
    echo "Schema creation failed."
    echo "$status" | jq -r '.details'
    break
  else
    echo "Schema creation is still processing. Waiting for 10 seconds..."
    sleep 10
  fi
done
