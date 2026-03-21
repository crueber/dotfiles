#!/bin/bash

set -e

CLAUDE_CREDS_FILE="$HOME/.claude/.credentials.json"
OPENCODE_AUTH_FILE="$HOME/.local/share/opencode/auth.json"

# Export from Keychain
echo "Fetching Claude Code credentials from Keychain..."
security find-generic-password -s "Claude Code-credentials" -w >"$CLAUDE_CREDS_FILE"

# Extract fields
ACCESS=$(jq -r '.claudeAiOauth.accessToken' "$CLAUDE_CREDS_FILE")
REFRESH=$(jq -r '.claudeAiOauth.refreshToken' "$CLAUDE_CREDS_FILE")
EXPIRES=$(jq -r '.claudeAiOauth.expiresAt' "$CLAUDE_CREDS_FILE")

if [[ -z "$ACCESS" || "$ACCESS" == "null" ]]; then
  echo "Error: could not extract credentials" >&2
  exit 1
fi
#
# Update anthropic entry in opencode auth.json
echo "Updating opencode auth.json..."
jq --arg access "$ACCESS" --arg refresh "$REFRESH" --arg expires "$EXPIRES" \
  '.anthropic = {"type": "oauth", "access": $access, "refresh": $refresh, "expires": $expires}' \
  "$OPENCODE_AUTH_FILE" >"${OPENCODE_AUTH_FILE}.tmp" && mv "${OPENCODE_AUTH_FILE}.tmp" "$OPENCODE_AUTH_FILE"

echo "Done."
