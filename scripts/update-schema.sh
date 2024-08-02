#!/bin/bash

# Load API details from the YAML file
API_ID=$(yq e '.api_id' src/Appsyncupdatemutations.yml)

# Update the schema in AppSync
aws appsync start-schema-creation --api-id $API_ID --definition file://src/schema.graphql

# Poll the schema creation status until it's done
while true; do
  STATUS=$(aws appsync get-schema-creation-status --api-id $API_ID --query 'status' --output text)
  echo "Current schema creation status: $STATUS"
  if [ "$STATUS" == "SUCCESS" ]; then
    echo "Schema creation succeeded."
    break
  elif [ "$STATUS" == "FAILED" ]; then
    echo "Schema creation failed."
    aws appsync get-schema-creation-status --api-id $API_ID --query 'details' --output text
    exit 1
  else
    echo "Schema creation is still processing. Waiting for 10 seconds..."
    sleep 10
  fi
done
