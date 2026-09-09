#!/bin/zsh
set -euo pipefail

script_dir=${0:A:h}
source_app="$script_dir/build/Teamute.app"
destination="/Applications/Teamute.app"
staging="/Applications/.Teamute.app.teamute-staging"
expected_bundle_id="local.teamute.app"

# An app bundle can be replaced while its old executable remains running.
# Stop only Teamute at this exact installed path before updating, so a later
# `open -a` cannot merely activate stale in-memory UI.
running_pids=$(/bin/ps -ax -o pid=,command= | /usr/bin/awk '$2 == "/Applications/Teamute.app/Contents/MacOS/Teamute" {print $1}')
if [[ -n "$running_pids" ]]; then
  kill -TERM ${(z)running_pids}
  for _ in {1..30}; do
    sleep 0.1
    still_running=$(/bin/ps -ax -o command= | /usr/bin/grep -Fx "/Applications/Teamute.app/Contents/MacOS/Teamute" || true)
    [[ -z "$still_running" ]] && break
  done
fi

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
