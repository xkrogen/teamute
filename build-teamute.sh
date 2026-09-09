#!/bin/zsh
set -euo pipefail

script_dir=${0:A:h}
app_path="$script_dir/build/Teamute.app"
signing_identity="${TEAMUTE_SIGNING_IDENTITY:-}"
module_cache=/tmp/teamute-app-clang-module-cache
mkdir -p "$script_dir/build"
stage_root="$(mktemp -d "$script_dir/build/.teamute.XXXXXX")"
stage_app="$stage_root/Teamute.app"
binary_path="$stage_app/Contents/MacOS/Teamute"
trap 'rm -rf "$stage_root"' EXIT

if [[ -z "$signing_identity" ]]; then
  signing_identity="$(security find-identity -v -p codesigning | sed -n 's/.*"\(Apple Development:.*\)"/\1/p' | head -n 1)"
fi
if [[ -z "$signing_identity" ]] || ! security find-identity -v -p codesigning | grep -Fq "\"$signing_identity\""; then
  echo "Required signing identity is unavailable: $signing_identity" >&2
  exit 1
fi
mkdir -p "$stage_app/Contents/MacOS" "$module_cache"
cp "$script_dir/Teamute/Info.plist" "$stage_app/Contents/Info.plist"
mkdir -p "$stage_app/Contents/Resources"
cp "$script_dir/icon.png" "$stage_app/Contents/Resources/icon.png"
swiftc -parse-as-library -Xcc "-fmodules-cache-path=$module_cache" \
  -framework AppKit -framework ApplicationServices -framework Carbon -framework CoreGraphics \
  "$script_dir/Teamute/Teamute.swift" -o "$binary_path"
codesign --force --options runtime --sign "$signing_identity" "$stage_app"
codesign --verify --deep --strict "$stage_app"
if [[ -e "$app_path" ]]; then chmod -R u+w "$app_path"; rm -rf "$app_path"; fi
mv "$stage_app" "$app_path"
chmod -R a-w "$app_path"
echo "Built: $app_path"
echo "Install/update: ./install-teamute.sh"
