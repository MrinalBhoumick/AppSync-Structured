#!/bin/bash

# Load API details from the YAML files
API_ID=$(yq e '.api_id' SAM/update-appsync.yml)
LAMBDA_FUNCTION_ARN=$(yq e '.lambda_function_arn' SAM/update-appsync.yml)
DATA_SOURCE="LambdaDataSource" 

# Ensure data source exists
bash scripts/create-update-data-source.sh

# Fetch queries from the YAML file
QUERIES=($(yq e '.queries[]' SAM/update-queries.yml))

# Update response mapping templates for queries
for query in "${QUERIES[@]}"; do
  echo "Updating response mapping template for query: $query"
  TEMPLATE_PATH="src/Queries/$query/response_mapping_template.graphql"
  if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "Response mapping template file not found for query: $query at $TEMPLATE_PATH"
    continue
  fi
  aws appsync get-resolver \
    --api-id $API_ID \
    --type-name Query \
    --field-name $query > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    aws appsync update-resolver \
      --api-id $API_ID \
      --type-name Query \
      --field-name $query \
      --response-mapping-template file://$TEMPLATE_PATH \
      --data-source-name $DATA_SOURCE \
      --kind UNIT
  else
    aws appsync create-resolver \
      --api-id $API_ID \
      --type-name Query \
      --field-name $query \
      --request-mapping-template file://src/Queries/$query/request_mapping_template.graphql \
      --response-mapping-template file://$TEMPLATE_PATH \
      --data-source-name $DATA_SOURCE \
      --kind UNIT
  fi
done

# Fetch mutations from the YAML file
MUTATIONS=($(yq e '.mutations[]' SAM/update-mutations.yml))

# Update response mapping templates for mutations
for mutation in "${MUTATIONS[@]}"; do
  echo "Updating response mapping template for mutation: $mutation"
  TEMPLATE_PATH="src/Mutations/$mutation/response_mapping_template.graphql"
  if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "Response mapping template file not found for mutation: $mutation at $TEMPLATE_PATH"
    continue
  fi
  aws appsync get-resolver \
    --api-id $API_ID \
    --type-name Mutation \
    --field-name $mutation > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    aws appsync update-resolver \
      --api-id $API_ID \
      --type-name Mutation \
      --field-name $mutation \
      --response-mapping-template file://$TEMPLATE_PATH \
      --data-source-name $DATA_SOURCE \
      --kind UNIT
  else
    aws appsync create-resolver \
      --api-id $API_ID \
      --type-name Mutation \
      --field-name $mutation \
      --request-mapping-template file://src/Mutations/$mutation/request_mapping_template.graphql \
      --response-mapping-template file://$TEMPLATE_PATH \
      --data-source-name $DATA_SOURCE \
      --kind UNIT
  fi
done
