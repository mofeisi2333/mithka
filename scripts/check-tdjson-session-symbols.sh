#!/bin/sh
set -eu

XCFRAMEWORK="${1:-ios/tdjson/tdjson.xcframework}"

if [ ! -d "$XCFRAMEWORK" ]; then
  echo "error: tdjson.xcframework not found: $XCFRAMEWORK" >&2
  exit 1
fi

if ! command -v nm >/dev/null 2>&1; then
  echo "error: nm is required to validate tdjson session backup symbols" >&2
  exit 1
fi

found_binary=0
missing=0
for binary in \
  "$XCFRAMEWORK/ios-arm64/tdjson.framework/tdjson" \
  "$XCFRAMEWORK/ios-arm64-simulator/tdjson.framework/tdjson"
do
  if [ ! -f "$binary" ]; then
    continue
  fi
  found_binary=1
  symbols="$(/usr/bin/nm -gU "$binary" 2>/dev/null || nm -g "$binary" 2>/dev/null || true)"
  for symbol in \
    _td_mithka_export_session_string \
    _td_mithka_import_session_string \
    _td_mithka_last_error
  do
    if ! printf '%s\n' "$symbols" | grep -q "$symbol"; then
      echo "error: $binary is missing $symbol" >&2
      missing=1
    fi
  done
done

if [ "$found_binary" -eq 0 ]; then
  echo "error: no tdjson framework binary found in $XCFRAMEWORK" >&2
  exit 1
fi

if [ "$missing" -ne 0 ]; then
  echo "error: tdjson.xcframework does not support Mithka TDLib session string backup" >&2
  echo "error: use the patched mithka-tdjson release asset or set TDJSON_XCFRAMEWORK_URL to one" >&2
  exit 1
fi

echo "✓ tdjson session string symbols available"
