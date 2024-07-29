#!/bin/bash

# Check if the file exists
if [ ! -f src/Appsyncupdate.yml ]; then
  echo "Error: src/Appsyncupdate.yml file not found"
  exit 1
fi

# Read the list of queries from the Appsyncupdate.yaml file
QUERY_LIST=$(yq eval '.queries[]' src/Appsyncupdate.yml)

# Update schema files for Queries
for query in $QUERY_LIST; do
  if [[ -d "src/Queries/$query" ]]; then
    aws appsync start-schema-creation \
      --api-id $API_ID \
      --definition file://src/Queries/$query/schema.graphql
  else
    echo "Directory src/Queries/$query not found"
  fi
done

# Read the list of mutations from the Appsyncupdate.yaml file
MUTATION_LIST=$(yq eval '.mutations[]' src/Appsyncupdate.yml)

# Update schema files for Mutations
for mutation in $MUTATION_LIST; do
  if [[ -d "src/Mutations/$mutation" ]]; then
    aws appsync start-schema-creation \
      --api-id $API_ID \
      --definition file://src/Mutations/$mutation/schema.graphql
  else
    echo "Directory src/Mutations/$mutation not found"
  fi
done
