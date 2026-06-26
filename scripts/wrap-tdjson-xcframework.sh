#!/usr/bin/env bash
#
# Converts the downloaded TDLib XCFramework from raw dylib slices into proper
# framework slices. App Store Connect rejects arbitrary app-embedded dylibs on
# iOS, even when the error is reported as Invalid Swift Support.
set -euo pipefail

if [[ $# -gt 0 ]]; then
  XCFRAMEWORK="$1"
else
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  XCFRAMEWORK="$REPO_ROOT/ios/tdjson/tdjson.xcframework"
fi

if [[ ! -d "$XCFRAMEWORK" ]]; then
  echo "error: missing tdjson XCFramework at $XCFRAMEWORK" >&2
  exit 1
fi

make_framework_plist() {
  local plist="$1"
  cat >"$plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>tdjson</string>
  <key>CFBundleIdentifier</key>
  <string>ad.neko.tdjson</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>tdjson</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>1.8.65</string>
  <key>CFBundleVersion</key>
  <string>1.8.65</string>
  <key>MinimumOSVersion</key>
  <string>13.0</string>
</dict>
</plist>
EOF
}

wrap_slice() {
  local identifier="$1"
  local dylib="$XCFRAMEWORK/$identifier/libtdjson.1.8.65.dylib"
  local framework="$XCFRAMEWORK/$identifier/tdjson.framework"
  local binary="$framework/tdjson"

  if [[ -f "$binary" ]]; then
    rm -f "$dylib"
    make_framework_plist "$framework/Info.plist"
    echo "tdjson framework slice already present: $identifier"
    return
  fi

  if [[ ! -f "$dylib" ]]; then
    echo "error: missing tdjson dylib slice: $dylib" >&2
    exit 1
  fi

  mkdir -p "$framework"
  cp -f "$dylib" "$binary"
  chmod 0755 "$binary"
  /usr/bin/install_name_tool -id "@rpath/tdjson.framework/tdjson" "$binary"
  make_framework_plist "$framework/Info.plist"
  rm -f "$dylib"
  echo "wrapped tdjson dylib slice as framework: $identifier"
}

sim_identifier=""
if [[ -d "$XCFRAMEWORK/ios-arm64_x86_64-simulator" ]]; then
  sim_identifier="ios-arm64_x86_64-simulator"
elif [[ -d "$XCFRAMEWORK/ios-arm64-simulator" ]]; then
  sim_identifier="ios-arm64-simulator"
else
  echo "error: missing tdjson simulator slice in $XCFRAMEWORK" >&2
  exit 1
fi

wrap_slice ios-arm64
wrap_slice "$sim_identifier"

sim_arch_xml='        <string>arm64</string>'
if [[ "$sim_identifier" == *x86_64* ]]; then
  sim_arch_xml="$sim_arch_xml
        <string>x86_64</string>"
fi

cat >"$XCFRAMEWORK/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>AvailableLibraries</key>
  <array>
    <dict>
      <key>BinaryPath</key>
      <string>tdjson.framework/tdjson</string>
      <key>LibraryIdentifier</key>
      <string>ios-arm64</string>
      <key>LibraryPath</key>
      <string>tdjson.framework</string>
      <key>SupportedArchitectures</key>
      <array>
        <string>arm64</string>
      </array>
      <key>SupportedPlatform</key>
      <string>ios</string>
    </dict>
    <dict>
      <key>BinaryPath</key>
      <string>tdjson.framework/tdjson</string>
      <key>LibraryIdentifier</key>
      <string>$sim_identifier</string>
      <key>LibraryPath</key>
      <string>tdjson.framework</string>
      <key>SupportedArchitectures</key>
      <array>
$sim_arch_xml
      </array>
      <key>SupportedPlatform</key>
      <string>ios</string>
      <key>SupportedPlatformVariant</key>
      <string>simulator</string>
    </dict>
  </array>
  <key>CFBundlePackageType</key>
  <string>XFWK</string>
  <key>XCFrameworkFormatVersion</key>
  <string>1.0</string>
</dict>
</plist>
EOF

echo "tdjson XCFramework is framework-based: $XCFRAMEWORK"
