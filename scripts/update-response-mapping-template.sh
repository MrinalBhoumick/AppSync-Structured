#!/bin/bash

# Load queries and mutations from the YAML files
QUERIES=$(yq e '.queries[]' src/Appsyncupdatequeries.yml)
MUTATIONS=$(yq e '.mutations[]' src/Appsyncupdatemutations.yml)

# Update response mapping templates for queries
for query in $QUERIES; do
  echo "Updating response mapping template for query: $query"
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name $query \
    --field-name $query \
    --data-source-name LambdaDataSource \
    --response-mapping-template file://src/Queries/$query/response_mapping_template.yml
done

# Update response mapping templates for mutations
for mutation in $MUTATIONS; do
  echo "Updating response mapping template for mutation: $mutation"
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name $mutation \
    --field-name $mutation \
    --data-source-name LambdaDataSource \
    --response-mapping-template file://src/Mutations/$mutation/response_mapping_template.yml
done
