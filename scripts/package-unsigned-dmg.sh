#!/bin/zsh
# Build an intentionally unsigned GitHub-release DMG from an exact version tag.
set -euo pipefail

repo_root="${0:A:h:h}"
tag="${1:-}"
[[ -n "$tag" ]] || { print -u2 "usage: $0 vX.Y.Z"; exit 2; }
[[ "$tag" =~ '^v[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.]+)?$' ]] || {
  print -u2 "release tag must be vX.Y.Z"; exit 2
}

plist="$repo_root/Teamute/Info.plist"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist")"
[[ "$tag" == "v$version" ]] || {
  print -u2 "tag $tag does not match CFBundleShortVersionString $version"; exit 2
}

build_root="$(mktemp -d /tmp/teamute-unsigned-dmg.XXXXXX)"
trap 'rm -rf "$build_root"' EXIT
app="$build_root/Teamute.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources" "$repo_root/dist"
cp "$plist" "$app/Contents/Info.plist"
cp "$repo_root/Teamute/Teamute.icns" "$app/Contents/Resources/Teamute.icns"

swiftc -parse-as-library \
  -framework AppKit -framework ApplicationServices -framework Carbon \
  -framework CoreGraphics -framework ServiceManagement \
  "$repo_root/Teamute/Teamute.swift" -o "$app/Contents/MacOS/Teamute"
"$app/Contents/MacOS/Teamute" --self-test
# Recent macOS toolchains can add an ad-hoc signature to swiftc output. Strip
# it so the public artifact is genuinely unsigned, not merely non-Developer-ID.
codesign --remove-signature "$app"

dmg="$repo_root/dist/Teamute-${version}-macOS-unsigned.dmg"
checksum="$dmg.sha256"
rm -f "$dmg" "$checksum"
hdiutil create -volname "Teamute ${version} (unsigned)" -srcfolder "$app" -ov -format UDZO "$dmg" >/dev/null
shasum -a 256 "$dmg" > "$checksum"
print "$dmg"
