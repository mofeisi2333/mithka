#!/usr/bin/env bash
#
# Ensures App Store archives include a dSYM bundle for the vendored TDLib dylib.
# The prebuilt TDLib binary is stripped, so dsymutil warns about missing detailed
# debug symbols, but it still writes a dSYM with the UUID App Store validation
# requires for the embedded libtdjson.1.8.65.dylib.
set -euo pipefail

if [[ "${EFFECTIVE_PLATFORM_NAME:-}" != "-iphoneos" ]]; then
  exit 0
fi

SRCROOT="${SRCROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../ios" && pwd)}"
TDJSON_DYLIB="$SRCROOT/tdjson/tdjson.xcframework/ios-arm64/libtdjson.1.8.65.dylib"
DSYM_DIR="${DWARF_DSYM_FOLDER_PATH:-}"
DSYM_PATH="$DSYM_DIR/libtdjson.1.8.65.dylib.dSYM"

if [[ ! -f "$TDJSON_DYLIB" ]]; then
  echo "error: missing $TDJSON_DYLIB" >&2
  exit 1
fi

if [[ -z "$DSYM_DIR" ]]; then
  echo "warning: DWARF_DSYM_FOLDER_PATH is empty; skipping tdjson dSYM packaging" >&2
  exit 0
fi

mkdir -p "$DSYM_DIR"
rm -rf "$DSYM_PATH"
/usr/bin/dsymutil "$TDJSON_DYLIB" -o "$DSYM_PATH"

echo "Packaged $(/usr/bin/dwarfdump --uuid "$DSYM_PATH" | sed 's/^/tdjson dSYM: /')"
