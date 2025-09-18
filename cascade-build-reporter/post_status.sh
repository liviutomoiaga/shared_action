#!/usr/bin/env bash
# Usage: post_status.sh --repo <repo> --sha <sha> --state <state> --context <context> --target_url <target_url> --description <description> --token <token>
set -euo pipefail

# Parse named arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --repo)
      REPO="$2"; shift 2;;
    --sha)
      SHA="$2"; shift 2;;
    --state)
      STATE="$2"; shift 2;;
    --context)
      CONTEXT="$2"; shift 2;;
    --target_url)
      TARGET_URL="$2"; shift 2;;
    --description)
      DESCRIPTION="$2"; shift 2;;
    --token)
      TOKEN="$2"; shift 2;;
    *)
      echo "Unknown argument: $1"; exit 1;;
  esac
done

# Check required arguments
for var in REPO SHA STATE CONTEXT TARGET_URL DESCRIPTION TOKEN; do
  if [[ -z "${!var:-}" ]]; then
    echo "Missing required argument: $var" >&2
    exit 1
  fi
done

curl -sS -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: Bearer $TOKEN" \
  "https://api.github.com/repos/$REPO/statuses/$SHA" \
  -d "{
    \"state\": \"$STATE\",
    \"context\": \"$CONTEXT\",
    \"target_url\": \"$TARGET_URL\",
    \"description\": \"$DESCRIPTION\"
  }"
