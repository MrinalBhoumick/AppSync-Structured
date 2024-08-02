#!/bin/bash

# Load API details from the YAML file
API_ID=$(yq e '.api_id' src/Appsyncupdatequeries.yml)
API_NAME=$(yq e '.api_name' src/Appsyncupdatequeries.yml)

if [ -z "$API_ID" ]; then
  echo "API ID not found. Please ensure the API exists."
  exit 1
fi

if [ -z "$API_NAME" ]; then
  echo "API Name not found. Please ensure it is defined in the YAML file."
  exit 1
fi

# Fetch queries and mutations from the YAML files
QUERIES=($(yq e '.queries[]' src/Appsyncupdatequeries.yml))
MUTATIONS=($(yq e '.mutations[]' src/Appsyncupdatemutations.yml))

# Update response mapping templates for queries
for query in "${QUERIES[@]}"; do
  echo "Updating response mapping template for query: $query"
  if [ ! -f "src/Queries/$query/response_mapping_template.yml" ]; then
    echo "Response mapping template file not found for query: $query"
    continue
  fi
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Query \
    --field-name $query \
    --response-mapping-template file://src/Queries/$query/response_mapping_template.yml
done

# Update response mapping templates for mutations
for mutation in "${MUTATIONS[@]}"; do
  echo "Updating response mapping template for mutation: $mutation"
  if [ ! -f "src/Mutations/$mutation/response_mapping_template.yml" ]; then
    echo "Response mapping template file not found for mutation: $mutation"
    continue
  fi
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Mutation \
    --field-name $mutation \
    --response-mapping-template file://src/Mutations/$mutation/response_mapping_template.yml
done
