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
  echo "Rollback flag detected. Reverting to the previous successful commit..."

  # Reset to the last successful commit
  git reset --hard HEAD~1

  # Clean the workspace to remove any changes made during the failed build
  git clean -fd

  # Remove the rollback flag
  rm -f rollback.flag

  echo "Rollback to previous successful commit completed."
else
  echo "No rollback needed."
fi
