#!/bin/sh
# Usage: post_status.sh --repo <owner/repo> --sha <sha> --state <state> --context <context> --target_url <url> --description <text> --token <token>
set -eu  # POSIX: -e (exit on error), -u (unset vars are errors)

# --- Parse named arguments (POSIX-safe) ---
REPO=""
SHA=""
STATE=""
CONTEXT=""
TARGET_URL=""
DESCRIPTION=""
TOKEN=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)        REPO="$2"; shift 2 ;;
    --sha)         SHA="$2"; shift 2 ;;
    --state)       STATE="$2"; shift 2 ;;
    --context)     CONTEXT="$2"; shift 2 ;;
    --target_url)  TARGET_URL="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --token)       TOKEN="$2"; shift 2 ;;
    --)            shift; break ;;
    *)             echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# --- Required args (POSIX parameter expansion with error messages) ---
: "${REPO:?Missing required argument: --repo}"
: "${SHA:?Missing required argument: --sha}"
: "${STATE:?Missing required argument: --state}"
: "${CONTEXT:?Missing required argument: --context}"
: "${TARGET_URL:?Missing required argument: --target_url}"
: "${DESCRIPTION:?Missing required argument: --description}"
: "${TOKEN:?Missing required argument: --token}"

# --- Minimal JSON escaping (quotes, backslashes, and newlines) ---
json_escape() {
  # Escapes \ and " and turns newlines into \n (portable sed)
  printf '%s' "$1" | sed \
    -e 's/\\/\\\\/g' \
    -e 's/"/\\"/g' \
    -e ':a;N;$!ba;s/\n/\\n/g'
}

STATE_ESC=$(json_escape "$STATE")
CONTEXT_ESC=$(json_escape "$CONTEXT")
TARGET_URL_ESC=$(json_escape "$TARGET_URL")
DESCRIPTION_ESC=$(json_escape "$DESCRIPTION")

# --- Build JSON payload without relying on bash features ---
payload=$(
  printf '{'
  printf '"state":"%s",' "$STATE_ESC"
  printf '"context":"%s",' "$CONTEXT_ESC"
  printf '"target_url":"%s",' "$TARGET_URL_ESC"
  printf '"description":"%s"' "$DESCRIPTION_ESC"
  printf '}'
)

# --- POST to GitHub Statuses API ---
curl -fSs -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: Bearer %s" \
  "https://api.github.com/repos/%s/statuses/%s" \
  -d "$payload" \
  "$(printf '%s' "$TOKEN")" \
  "$(printf '%s' "$REPO")" \
  "$(printf '%s' "$SHA")"
