#!/bin/bash

# Load API details from YAML file
API_ID=$(yq e '.api_id' SAM/update-appsync.yml)
LAMBDA_FUNCTION_ARN=$(yq e '.lambda_function_arn' SAM/update-appsync.yml)
DATA_SOURCE="LambdaDataSource"
REGION=$(yq e '.region' SAM/update-appsync.yml)

# Ensure the existence of the Lambda data source
chmod +x ./scripts/create-update-data-source.sh
./scripts/create-update-data-source.sh

# Fetch queries from the YAML file
QUERIES=($(yq e '.queries[]' SAM/update-queries.yml))

# Update mapping templates for queries
for query in "${QUERIES[@]}"; do
  echo "Updating request and response mapping templates for query: $query"
  REQUEST_TEMPLATE_PATH="src/Queries/$query/request_mapping_template.graphql"
  RESPONSE_TEMPLATE_PATH="src/Queries/$query/response_mapping_template.graphql"
  
  aws appsync update-resolver --api-id $API_ID --region $REGION --type-name "Query" --field-name "$query" \
    --data-source-name "$DATA_SOURCE" \
    --request-mapping-template file://$REQUEST_TEMPLATE_PATH \
    --response-mapping-template file://$RESPONSE_TEMPLATE_PATH
done

# Fetch mutations from the YAML file
MUTATIONS=($(yq e '.mutations[]' SAM/update-mutations.yml))

# Update mapping templates for mutations
for mutation in "${MUTATIONS[@]}"; do
  echo "Updating request and response mapping templates for mutation: $mutation"
  REQUEST_TEMPLATE_PATH="src/Mutations/$mutation/request_mapping_template.graphql"
  RESPONSE_TEMPLATE_PATH="src/Mutations/$mutation/response_mapping_template.graphql"
  
  aws appsync update-resolver --api-id $API_ID --region $REGION --type-name "Mutation" --field-name "$mutation" \
    --data-source-name "$DATA_SOURCE" \
    --request-mapping-template file://$REQUEST_TEMPLATE_PATH \
    --response-mapping-template file://$RESPONSE_TEMPLATE_PATH
done

echo "Mapping templates update completed."
