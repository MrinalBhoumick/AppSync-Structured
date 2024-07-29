#!/bin/bash

# Read the list of queries and mutations from the Appsyncupdate.yaml file
queries=$(yq e '.queries' src/Appsyncupdate.yaml)
mutations=$(yq e '.mutations' src/Appsyncupdate.yaml)

# Update schema for Queries
for query in $queries; do
  if [[ -n "$query" ]]; then
    echo "Updating schema for query: $query"
    aws appsync start-schema-creation \
      --api-id $API_ID \
      --definition file://src/Queries/$query/schema.graphql
  fi
done

# Update schema for Mutations
for mutation in $mutations; do
  if [[ -n "$mutation" ]]; then
    echo "Updating schema for mutation: $mutation"
    aws appsync start-schema-creation \
      --api-id $API_ID \
      --definition file://src/Mutations/$mutation/schema.graphql
  fi
done
