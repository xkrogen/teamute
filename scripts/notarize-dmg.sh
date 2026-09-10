#!/bin/zsh
# Submit, staple, and validate a Developer ID DMG. Credentials are supplied by
# a local keychain profile or CI environment; no secret is written to the repo.
set -euo pipefail

dmg=${1:?"usage: $0 path/to/Teamute-x.y.z.dmg"}
[[ -f "$dmg" ]] || { print -u2 "DMG not found: $dmg"; exit 2; }
profile=${TEAMUTE_NOTARY_PROFILE:-}
key=${TEAMUTE_NOTARY_KEY:-}
key_id=${TEAMUTE_NOTARY_KEY_ID:-}
issuer=${TEAMUTE_NOTARY_ISSUER_ID:-}
args=()
if [[ -n "$profile" ]]; then
  args=(--keychain-profile "$profile")
elif [[ -n "$key" && -n "$key_id" && -n "$issuer" ]]; then
  [[ -f "$key" ]] || { print -u2 'TEAMUTE_NOTARY_KEY does not name a file.'; exit 2; }
  args=(--key "$key" --key-id "$key_id" --issuer "$issuer")
else
  print -u2 'Set TEAMUTE_NOTARY_PROFILE or TEAMUTE_NOTARY_KEY, TEAMUTE_NOTARY_KEY_ID, and TEAMUTE_NOTARY_ISSUER_ID.'
  exit 2
fi

result=$(mktemp /tmp/teamute-notary-result.XXXXXX.json)
trap 'rm -f "$result"' EXIT
set +e
xcrun notarytool submit "$dmg" "${args[@]}" --wait --output-format json >"$result"
status=$?
set -e
notary_status=$(plutil -extract status raw -o - "$result" 2>/dev/null || true)
if [[ $status -ne 0 || "$notary_status" != "Accepted" ]]; then
  submission_id=$(plutil -extract id raw -o - "$result" 2>/dev/null || true)
  [[ -n "$submission_id" ]] && xcrun notarytool log "$submission_id" "${args[@]}" || true
  print -u2 'Notarization failed; inspect the safe notary log above.'
  exit 1
fi
xcrun stapler staple "$dmg"
xcrun stapler validate "$dmg"
spctl -a -vvv -t open --context context:primary-signature "$dmg"
print -- "Notarized and stapled: $dmg"
