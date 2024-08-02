#!/bin/bash

# Load queries and mutations from the YAML files
QUERIES=$(yq e '.queries[]' src/Appsyncupdatequeries.yml)
MUTATIONS=$(yq e '.mutations[]' src/Appsyncupdatemutations.yml)

# Update request mapping templates for queries
for query in $QUERIES; do
  echo "Updating request mapping template for query: $query"
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name $query \
    --field-name $query \
    --data-source-name LambdaDataSource \
    --request-mapping-template file://src/Queries/$query/request_mapping_template.yml
done

# Update request mapping templates for mutations
for mutation in $MUTATIONS; do
  echo "Updating request mapping template for mutation: $mutation"
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name $mutation \
    --field-name $mutation \
    --data-source-name LambdaDataSource \
    --request-mapping-template file://src/Mutations/$mutation/request_mapping_template.yml
done
