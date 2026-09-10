#!/bin/zsh
# Build a Developer ID-signed DMG. This intentionally does not use the local
# Apple Development identity selected by build-teamute.sh.
set -euo pipefail

repo=${0:A:h:h}
tag=${1:?"usage: $0 v<version>"}
plist="$repo/Teamute/Info.plist"
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")
[[ "$tag" == "v$version" ]] || { print -u2 "Tag $tag must match CFBundleShortVersionString v$version"; exit 2; }

identity=${TEAMUTE_DEVELOPER_ID_IDENTITY:-}
keychain=${TEAMUTE_KEYCHAIN:-}
identity_args=()
[[ -n "$keychain" ]] && identity_args=(-k "$keychain")
if [[ -z "$identity" ]]; then
  identity=$(security find-identity -v -p codesigning "${identity_args[@]}" | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' | head -n 1)
fi
[[ -n "$identity" ]] || { print -u2 'Developer ID Application certificate is required.'; exit 2; }
[[ "$identity" == 'Developer ID Application:'* ]] || { print -u2 'Release signing identity must be a Developer ID Application certificate.'; exit 2; }
security find-identity -v -p codesigning "${identity_args[@]}" | grep -Fq "\"$identity\"" || { print -u2 'Requested Developer ID identity is unavailable.'; exit 2; }

stage=$(mktemp -d /tmp/teamute-release.XXXXXX)
trap 'rm -rf "$stage"' EXIT
app="$stage/Teamute.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources" "$repo/dist"
cp "$plist" "$app/Contents/Info.plist"
cp "$repo/Teamute/Teamute.icns" "$app/Contents/Resources/Teamute.icns"
swiftc -parse-as-library -framework AppKit -framework ApplicationServices -framework Carbon -framework CoreGraphics -framework ServiceManagement "$repo/Teamute/Teamute.swift" -o "$app/Contents/MacOS/Teamute"
sign_args=(--force --sign "$identity" --options runtime --timestamp --entitlements "$repo/Teamute/Distribution.entitlements")
[[ -n "$keychain" ]] && sign_args+=(--keychain "$keychain")
codesign "${sign_args[@]}" "$app"
codesign --verify --deep --strict --verbose=2 "$app"
codesign -dvv "$app" 2>&1 | grep -q 'Timestamp=' || { print -u2 'Developer ID signature is missing a secure timestamp.'; exit 1; }
get_task_allow=$(plutil -extract com.apple.security.get-task-allow raw -o - "$repo/Teamute/Distribution.entitlements" 2>/dev/null || true)
[[ "$get_task_allow" != true ]] || { print -u2 'Distribution build must not enable get-task-allow.'; exit 1; }

dmg="$repo/dist/Teamute-$version.dmg"
rm -f "$dmg"
hdiutil create -volname "Teamute $version" -srcfolder "$app" -ov -format UDZO "$dmg"
print -- "$dmg"
