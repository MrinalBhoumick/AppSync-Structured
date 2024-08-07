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

# Check if rollback.flag exists
if [ -f rollback.flag ]; then
  echo "Rollback flag detected. Reverting to the previous successful build..."

  # Check if the artifact exists in the S3 bucket
  if [ -f artifacts/last-successful-build.tar.gz ]; then
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
