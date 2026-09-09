#!/bin/zsh
set -euo pipefail

script_dir=${0:A:h}
source_app="$script_dir/build/Teamute.app"
destination="/Applications/Teamute.app"
staging="/Applications/.Teamute.app.teamute-staging"
expected_bundle_id="local.teamute.app"

[[ -d "$source_app" ]] || { echo "Build Teamute first with ./build-teamute.sh" >&2; exit 1; }
codesign --verify --deep --strict "$source_app"
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$source_app/Contents/Info.plist")" == "$expected_bundle_id" ]] || {
  echo "Source bundle identity is not Teamute" >&2; exit 1
}

if [[ -e "$destination" ]]; then
  [[ -f "$destination/Contents/Info.plist" ]] || { echo "Refusing to replace non-app destination: $destination" >&2; exit 1; }
  [[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$destination/Contents/Info.plist")" == "$expected_bundle_id" ]] || {
    echo "Refusing to replace a non-Teamute app at $destination" >&2; exit 1
  }
fi

rm -rf "$staging"
ditto "$source_app" "$staging"
codesign --verify --deep --strict "$staging"
if [[ -e "$destination" ]]; then
  chmod -R u+w "$destination"
  rm -rf "$destination"
fi
mv "$staging" "$destination"
chmod -R a-w "$destination"
codesign --verify --deep --strict "$destination"
echo "Installed: $destination"
