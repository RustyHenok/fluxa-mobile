#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_PATH="${BACKEND_OPENAPI_PATH:-$ROOT_DIR/../fluxa-backend/openapi/fluxa-openapi.json}"
TARGET_DIR="$ROOT_DIR/contracts"
TARGET_PATH="$TARGET_DIR/fluxa-openapi.json"

if [[ ! -f "$SOURCE_PATH" ]]; then
  printf 'OpenAPI source file not found: %s\n' "$SOURCE_PATH" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$SOURCE_PATH" "$TARGET_PATH"
printf 'Synced OpenAPI contract to %s\n' "$TARGET_PATH"
