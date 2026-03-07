#!/usr/bin/env bash

set -euo pipefail

required_vars=(
  FIREBASE_API_KEY
  FIREBASE_APP_ID
  FIREBASE_MESSAGING_SENDER_ID
  FIREBASE_PROJECT_ID
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing required environment variable: ${var_name}"
    exit 1
  fi
done

flutter build web --release \
  --dart-define=FIREBASE_API_KEY="${FIREBASE_API_KEY}" \
  --dart-define=FIREBASE_APP_ID="${FIREBASE_APP_ID}" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="${FIREBASE_MESSAGING_SENDER_ID}" \
  --dart-define=FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID}" \
  --dart-define=FIREBASE_AUTH_DOMAIN="${FIREBASE_AUTH_DOMAIN:-}" \
  --dart-define=FIREBASE_STORAGE_BUCKET="${FIREBASE_STORAGE_BUCKET:-}" \
  --dart-define=FIREBASE_MEASUREMENT_ID="${FIREBASE_MEASUREMENT_ID:-}"

firebase deploy --only hosting
