#!/bin/bash

# Fetch the list of queries and mutations from the Appsyncupdate.yaml file
QUERY_LIST=$(yq e '.queries' src/Appsyncupdate.yml)
MUTATION_LIST=$(yq e '.mutations' src/Appsyncupdate.yml)

# Common variables
DATA_SOURCE_NAME="LambdaDataSource"
LAMBDA_AUTHORIZER_CONFIG="authorizerUri=arn:aws:lambda:ap-south-1:992382729083:function:commercial_cost_center"

# Update response mapping templates for Queries
for query in $QUERY_LIST; do
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Query \
    --field-name $query \
    --data-source-name $DATA_SOURCE_NAME \
    --response-mapping-template file://src/Queries/$query/response_mapping_template.graphql \
    --authorization-config lambdaAuthorizerConfig={$LAMBDA_AUTHORIZER_CONFIG}
done

# Update response mapping templates for Mutations
for mutation in $MUTATION_LIST; do
  aws appsync update-resolver \
    --api-id $API_ID \
    --type-name Mutation \
    --field-name $mutation \
    --data-source-name $DATA_SOURCE_NAME \
    --response-mapping-template file://src/Mutations/$mutation/response_mapping_template.graphql \
    --authorization-config lambdaAuthorizerConfig={$LAMBDA_AUTHORIZER_CONFIG}
done
