#!/bin/bash

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
