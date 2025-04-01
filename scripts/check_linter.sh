#!/bin/bash
# check_linter.sh

# Run RuboCop using Bundler
make linter
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "RuboCop failed with exit code $EXIT_CODE."
  exit $EXIT_CODE
fi

echo "RuboCop passed successfully."
exit 0