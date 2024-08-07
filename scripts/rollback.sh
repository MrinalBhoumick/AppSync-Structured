#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "git command not found. Please ensure git is installed."
  exit 1
fi

# Navigate to the repository directory
REPO_DIR="/codebuild/repo" # Adjust this path as needed
if [ -d "$REPO_DIR" ]; then
  cd "$REPO_DIR" || { echo "Failed to navigate to $REPO_DIR"; exit 1; }
else
  echo "Repository directory $REPO_DIR not found."
  exit 1
fi

# Fetch S3 bucket name from environment variable
if [ -z "$S3_BUCKET" ]; then
  echo "S3_BUCKET environment variable is not set."
  exit 1
fi

# Check if rollback.flag exists
if [ -f rollback.flag ]; then
  echo "Rollback flag detected. Reverting to the previous successful build..."

  # Check if the artifact exists in the S3 bucket
  if aws s3 ls "s3://$S3_BUCKET/last-successful-build.tar.gz" &> /dev/null; then
    # Download the last successful build from S3
    aws s3 cp "s3://$S3_BUCKET/last-successful-build.tar.gz" artifacts/last-successful-build.tar.gz

    # Extract the last successful build
    tar -xzf artifacts/last-successful-build.tar.gz -C .

    # Clean the workspace to remove any changes made during the failed build
    git clean -fd

    # Remove the rollback flag
    rm -f rollback.flag

    echo "Rollback to previous successful build completed."
  else
    echo "No previous successful build artifact found in S3. Cannot perform rollback."
    exit 1
  fi
else
  echo "No rollback needed."
fi
