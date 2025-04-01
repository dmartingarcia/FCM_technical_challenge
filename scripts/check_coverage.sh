#!/bin/bash
# check_coverage.sh

# Check if the coverage file exists; we can execute it
if [ ! -f coverage/.last_run.json ]; then
  make test
fi

# Expect the minimum coverage percentage as the first argument.
MIN_COVERAGE=90

# Use jq to extract the 'line' coverage value from the JSON file.
COV_PERCENT=$(jq -r '.result.line' coverage/.last_run.json)

# Use awk to compare the floating-point numbers.
# It prints "1" if the coverage is below the minimum, or "0" otherwise.
is_below=$(awk -v cov="$COV_PERCENT" -v min="$MIN_COVERAGE" 'BEGIN { print (cov < min) ? 1 : 0 }')

if [ "$is_below" -eq 1 ]; then
  echo "Coverage ${COV_PERCENT}% < required ${MIN_COVERAGE}%"
  exit 1
fi

echo "Coverage is over the minimum percentage: ${COV_PERCENT}% > ${MIN_COVERAGE}%."
exit 0
