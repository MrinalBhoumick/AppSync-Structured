#!/bin/bash

# Fetch the API details from the Appsyncupdate.yaml file
API_ID=$(yq e '.api_id' src/Appsyncupdate.yaml)
SCHEMA_FILE="src/schema.graphql"

# Start schema creation
response=$(aws appsync start-schema-creation \
  --api-id $API_ID \
  --definition file://$SCHEMA_FILE)

echo "Schema creation started: $response"

# Loop to check the status of schema creation
while true; do
  status=$(aws appsync get-schema-creation-status --api-id $API_ID | jq -r '.status')
  echo "Current schema creation status: $status"
  if [[ $status == "SUCCESS" ]]; then
    echo "Schema creation completed successfully."
    break
  elif [[ $status == "FAILED" ]]; then
    echo "Schema creation failed."
    aws appsync get-schema-creation-status --api-id $API_ID
    exit 1
  else
    echo "Schema creation is still processing. Waiting for 10 seconds..."
    sleep 10
  fi
done
