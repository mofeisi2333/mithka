#!/usr/bin/env bash
#
# Branch-only App Store packaging experiment:
# copy the Swift runtime dylibs Apple reported into Runner.app/Frameworks during
# the archive, before Xcode signs and exports the app.
set -euo pipefail

if [[ "${EFFECTIVE_PLATFORM_NAME:-}" != "-iphoneos" ]]; then
  exit 0
fi

DEST_DIR="${TARGET_BUILD_DIR:?}/${FRAMEWORKS_FOLDER_PATH:?}"
SWIFT_RUNTIME_DIR="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.0/iphoneos"

if [[ ! -d "$SWIFT_RUNTIME_DIR" ]]; then
  echo "error: missing Swift runtime directory: $SWIFT_RUNTIME_DIR" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
swift_support_dir=""
if [[ -n "${SWIFT_STDLIB_TOOL_UNSIGNED_DESTINATION_DIR:-}" ]]; then
  swift_support_dir="${SWIFT_STDLIB_TOOL_UNSIGNED_DESTINATION_DIR}/iphoneos"
  mkdir -p "$swift_support_dir"
fi

libs=(
  libswiftAVFoundation.dylib
  libswiftCore.dylib
  libswiftCoreAudio.dylib
  libswiftCoreFoundation.dylib
  libswiftCoreGraphics.dylib
  libswiftCoreImage.dylib
  libswiftCoreLocation.dylib
  libswiftCoreMedia.dylib
  libswiftDarwin.dylib
  libswiftDispatch.dylib
  libswiftFoundation.dylib
  libswiftMapKit.dylib
  libswiftMetal.dylib
  libswiftObjectiveC.dylib
  libswiftPhotos.dylib
  libswiftQuartzCore.dylib
  libswiftUIKit.dylib
  libswiftos.dylib
  libswiftsimd.dylib
)

sign_identity="${EXPANDED_CODE_SIGN_IDENTITY:-}"
if [[ -z "$sign_identity" && "${CODE_SIGNING_ALLOWED:-YES}" != "NO" ]]; then
  sign_identity="-"
fi

copied=0
support_copied=0
for lib in "${libs[@]}"; do
  src="$SWIFT_RUNTIME_DIR/$lib"
  dst="$DEST_DIR/$lib"
  if [[ ! -f "$src" ]]; then
    echo "error: missing Swift runtime dylib: $src" >&2
    exit 1
  fi

  /bin/cp -f "$src" "$dst"
  /bin/chmod 0755 "$dst"

  if [[ "${CODE_SIGNING_ALLOWED:-YES}" != "NO" && -n "$sign_identity" ]]; then
    /usr/bin/codesign --force --sign "$sign_identity" "$dst"
  fi

  if [[ -n "$swift_support_dir" ]]; then
    /bin/cp -f "$src" "$swift_support_dir/$lib"
    /bin/chmod 0644 "$swift_support_dir/$lib"
    support_copied=$((support_copied + 1))
  fi
  copied=$((copied + 1))
done

echo "Embedded $copied Swift runtime dylibs into $DEST_DIR"
if [[ -n "$swift_support_dir" ]]; then
  echo "Prepared $support_copied SwiftSupport dylibs in $swift_support_dir"
fi
