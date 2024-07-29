#!/bin/bash

# Read the list of queries from the file
QUERY_LIST=$(cat queries.txt)

# Update request mapping templates for Queries
for query in $QUERY_LIST; do
  if [[ -f src/Queries/$query/request_mapping_template.graphql ]]; then
    aws appsync update-resolver \
      --api-id $API_ID \
      --type-name Query \
      --field-name $query \
      --request-mapping-template file://src/Queries/$query/request_mapping_template.graphql \
      --response-mapping-template file://src/Queries/$query/response_mapping_template.graphql \
      --data-source-name LambdaDataSource
  fi
done

# Read the list of mutations from the file
MUTATION_LIST=$(cat mutations.txt)

# Update request mapping templates for Mutations
for mutation in $MUTATION_LIST; do
  if [[ -f src/Mutations/$mutation/request_mapping_template.graphql ]]; then
    aws appsync update-resolver \
      --api-id $API_ID \
      --type-name Mutation \
      --field-name $mutation \
      --request-mapping-template file://src/Mutations/$mutation/request_mapping_template.graphql \
      --response-mapping-template file://src/Mutations/$mutation/response_mapping_template.graphql \
      --data-source-name LambdaDataSource
  fi
done
