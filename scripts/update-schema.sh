#!/bin/bash

function wait_for_schema_ready() {
  local retry_count=0
  local max_retries=10
  local delay=30 

  while [ $retry_count -lt $max_retries ]; do
    local status=$(aws appsync get-graphql-api --api-id $API_ID --query 'graphqlApi.status' --output text)
    
    if [ "$status" == "ACTIVE" ]; then
      echo "Schema is ready for updates."
      return 0
    fi

    echo "Schema is not ready. Retrying in $delay seconds..."
    sleep $delay
    delay=$((delay * 2)) # Exponential backoff
    retry_count=$((retry_count + 1))
  done

  echo "Failed to wait for schema readiness after $max_retries attempts."
  return 1
}

if [ $? -eq 0 ]; then
  aws appsync start-schema-creation \
    --api-id $API_ID \
    --definition file://src/schema.graphql
fi
