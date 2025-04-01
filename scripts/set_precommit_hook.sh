#!/bin/bash
# set_precommit_hook.sh
# This script ensures that the Git pre-commit hook calls your
# scripts/check_coverage.sh and scripts/check_linter.sh.
# If the pre-commit hook already exists, it will add the commands
# only if they’re not already present.

# Change to the root directory of your Git repository if needed.
cd "$(git rev-parse --show-toplevel)" || exit 1

HOOK_FILE=".git/hooks/pre-commit"

# If the hook file doesn't exist, create it with the a classic shebang!
if [ ! -f "$HOOK_FILE" ]; then
  echo "Creating new pre-commit hook file."
  echo "#!/bin/sh" > "$HOOK_FILE"
  echo "cd \"$(git rev-parse --show-toplevel)\"" > "$HOOK_FILE"
fi

# Ensure the hook is executable.
chmod +x "$HOOK_FILE"

# Add check_coverage.sh if not already in the hook.
if ! grep -q "scripts/check_coverage.sh" "$HOOK_FILE"; then
  echo "Adding scripts/check_coverage.sh to pre-commit hook."
  {
    echo ""
    echo "# Run coverage check"
    echo "sh scripts/check_coverage.sh"
  } >> "$HOOK_FILE"
fi

# Add check_linter.sh if not already in the hook.
if ! grep -q "scripts/check_linter.sh" "$HOOK_FILE"; then
  echo "Adding scripts/check_linter.sh to pre-commit hook."
  {
    echo ""
    echo "# Run linter check"
    echo "sh scripts/check_linter.sh"
  } >> "$HOOK_FILE"
fi

echo "Pre-commit hook updated successfully."