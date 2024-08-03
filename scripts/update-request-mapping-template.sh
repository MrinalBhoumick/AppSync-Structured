#!/bin/bash

# Load API details from the YAML files
API_ID=$(yq e '.api_id' src/Appsyncupdatequeries.yml)
LAMBDA_FUNCTION_ARN=$(yq e '.lambda_function_arn' src/Appsyncupdatequeries.yml)
DATA_SOURCE="LambdaDataSource"  # Data source name

# Ensure data source exists
bash scripts/create-update-data-source.sh

# Fetch queries from the YAML file
QUERIES=($(yq e '.queries[]' src/Appsyncupdatequeries.yml))

# Update request mapping templates for queries
for query in "${QUERIES[@]}"; do
  echo "Updating request mapping template for query: $query"
  TEMPLATE_PATH="src/Queries/$query/request_mapping_template.graphql"
  if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "Request mapping template file not found for query: $query at $TEMPLATE_PATH"
    continue
  fi
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Query \
    --field-name $query \
    --request-mapping-template file://$TEMPLATE_PATH \
    --data-source $DATA_SOURCE
done

# Fetch mutations from the YAML file
MUTATIONS=($(yq e '.mutations[]' src/Appsyncupdatemutations.yml))

# Update request mapping templates for mutations
for mutation in "${MUTATIONS[@]}"; do
  echo "Updating request mapping template for mutation: $mutation"
  TEMPLATE_PATH="src/Mutations/$mutation/request_mapping_template.graphql"
  if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "Request mapping template file not found for mutation: $mutation at $TEMPLATE_PATH"
    continue
  fi
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Mutation \
    --field-name $mutation \
    --request-mapping-template file://$TEMPLATE_PATH \
    --data-source $DATA_SOURCE
done
