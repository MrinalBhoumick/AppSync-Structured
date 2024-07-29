#!/bin/bash

# Data Source Name
DATA_SOURCE_NAME="LambdaDataSource"

# Fetch queries from Appsyncupdate.yaml
QUERY_LIST=$(yq e '.queries[]' src/Appsyncupdate.yaml)

# Update request mapping templates for Queries
for query in $QUERY_LIST; do
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Query \
    --field-name $query \
    --request-mapping-template file://src/Queries/$query/request_mapping_template.graphql \
    --response-mapping-template file://src/Queries/$query/response_mapping_template.graphql \
    --data-source-name $DATA_SOURCE_NAME
done

# Fetch mutations from Appsyncupdate.yaml
MUTATION_LIST=$(yq e '.mutations[]' src/Appsyncupdate.yaml)

# Update request mapping templates for Mutations
for mutation in $MUTATION_LIST; do
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Mutation \
    --field-name $mutation \
    --request-mapping-template file://src/Mutations/$mutation/request_mapping_template.graphql \
    --response-mapping-template file://src/Mutations/$mutation/response_mapping_template.graphql \
    --data-source-name $DATA_SOURCE_NAME
done
