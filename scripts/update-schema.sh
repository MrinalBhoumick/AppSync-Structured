#!/bin/bash

# Start schema creation
echo "Starting schema creation..."

# Replace with your actual command to create/update the schema
SCHEMA_UPDATE_STATUS=$(aws appsync start-schema-creation --api-id $API_ID --definition file://$SCHEMA_FILE)

# Check status of schema creation
STATUS=$(echo $SCHEMA_UPDATE_STATUS | jq -r .status)

# Poll the status
while [ "$STATUS" == "PROCESSING" ]; do
  echo "Current schema creation status: $STATUS"
  sleep 10
  SCHEMA_UPDATE_STATUS=$(aws appsync get-schema --api-id $API_ID)
  STATUS=$(echo $SCHEMA_UPDATE_STATUS | jq -r .status)
done

# Final status check
if [ "$STATUS" == "FAILED" ]; then
  echo "Schema creation failed."
  touch rollback.flag
  exit 1
fi

echo "Schema creation completed successfully."
