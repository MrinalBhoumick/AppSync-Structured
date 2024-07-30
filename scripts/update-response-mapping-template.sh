#!/bin/bash

# Fetch the list of queries and mutations from the Appsyncupdate.yaml file
QUERY_LIST=$(yq e '.queries[]' src/Appsyncupdate.yml)
MUTATION_LIST=$(yq e '.mutations[]' src/Appsyncupdate.yml)

# Common variables
DATA_SOURCE_NAME="LambdaDataSource"

# Update GraphQL API with AWS Lambda authorization
aws appsync update-graphql-api \
  --api-id $API_ID \
  --name $API_NAME \
  --authentication-type AWS_LAMBDA \
  --lambda-authorizer-config authorizerUri="$LAMBDA_AUTHORIZER_ARN"

# Update response mapping templates for Queries
for query in $QUERY_LIST; do
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Query \
    --field-name $query \
    --data-source-name $DATA_SOURCE_NAME \
    --response-mapping-template file://src/Queries/$query/response_mapping_template.graphql
done

# Update response mapping templates for Mutations
for mutation in $MUTATION_LIST; do
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Mutation \
    --field-name $mutation \
    --data-source-name $DATA_SOURCE_NAME \
    --response-mapping-template file://src/Mutations/$mutation/response_mapping_template.graphql
done
