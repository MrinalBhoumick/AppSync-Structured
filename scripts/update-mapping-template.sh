#!/bin/bash

# Load API details from YAML file
API_ID=$(yq e '.api_id' SAM/update-appsync.yml)
LAMBDA_FUNCTION_ARN=$(yq e '.lambda_function_arn' SAM/update-appsync.yml)
DATA_SOURCE="LambdaDataSource"
REGION=$(yq eval '.region' SAM/update-appsync.yml)

# Ensure the existence of the Lambda data source
chmod +x ./scripts/create-update-data-source.sh
./scripts/create-update-data-source.sh

# Function to update or create resolver
update_or_create_resolver() {
  local type_name=$1
  local field_name=$2
  local request_template_path=$3
  local response_template_path=$4
  
  # Check if resolver exists
  aws appsync get-resolver --api-id $API_ID --region $REGION --type-name "$type_name" --field-name "$field_name" >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "Updating resolver for $type_name: $field_name"
    aws appsync update-resolver --api-id $API_ID --region $REGION --type-name "$type_name" --field-name "$field_name" \
      --data-source-name "$DATA_SOURCE" \
      --request-mapping-template file://$request_template_path \
      --response-mapping-template file://$response_template_path
  else
    echo "Creating resolver for $type_name: $field_name"
    aws appsync create-resolver --api-id $API_ID --region $REGION --type-name "$type_name" --field-name "$field_name" \
      --data-source-name "$DATA_SOURCE" \
      --request-mapping-template file://$request_template_path \
      --response-mapping-template file://$response_template_path
  fi
}

# Fetch queries from the YAML file
QUERIES=($(yq e '.queries[]' SAM/update-queries.yml))

# Update or create resolvers for queries
for query in "${QUERIES[@]}"; do
  echo "Processing query: $query"
  REQUEST_TEMPLATE_PATH="src/Queries/$query/request_mapping_template.graphql"
  RESPONSE_TEMPLATE_PATH="src/Queries/$query/response_mapping_template.graphql"
  
  update_or_create_resolver "Query" "$query" "$REQUEST_TEMPLATE_PATH" "$RESPONSE_TEMPLATE_PATH"
done

# Fetch mutations from the YAML file
MUTATIONS=($(yq e '.mutations[]' SAM/update-mutations.yml))

# Update or create resolvers for mutations
for mutation in "${MUTATIONS[@]}"; do
  echo "Processing mutation: $mutation"
  REQUEST_TEMPLATE_PATH="src/Mutations/$mutation/request_mapping_template.graphql"
  RESPONSE_TEMPLATE_PATH="src/Mutations/$mutation/response_mapping_template.graphql"
  
  update_or_create_resolver "Mutation" "$mutation" "$REQUEST_TEMPLATE_PATH" "$RESPONSE_TEMPLATE_PATH"
done

echo "Mapping templates update completed."
