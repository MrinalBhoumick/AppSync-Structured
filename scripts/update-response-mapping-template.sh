#!/bin/bash

# Load environment variables from GitHub Actions secrets or CodeBuild environment variables
API_ID=$API_ID

# Extract queries and mutations from the Appsyncupdate.yaml file
QUERY_LIST=$(yq eval '.queries[]' src/Appsyncupdate.yaml)
MUTATION_LIST=$(yq eval '.mutations[]' src/Appsyncupdate.yaml)

# Update response mapping templates for Queries
for query in $QUERY_LIST; do
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Query \
    --field-name $query \
    --response-mapping-template file://src/Queries/$query/response_mapping_template.graphql
done

# Update response mapping templates for Mutations
for mutation in $MUTATION_LIST; do
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Mutation \
    --field-name $mutation \
    --response-mapping-template file://src/Mutations/$mutation/response_mapping_template.graphql
done
