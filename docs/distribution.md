# Direct distribution

Teamute is distributed directly as a notarized DMG. It is not on the Mac App
Store roadmap.

## One-time owner setup

1. An Apple Developer Program Account Holder creates a **Developer ID
   Application** certificate. Do not use an Apple Development certificate for
   releases.
2. Create an Apple notarization API key. Keep the `.p8` key private.
3. The repository’s `release` environment is restricted to `v*` tags. Add
   required reviewers in GitHub before storing production credentials, then
   add these environment secrets:

   - `TEAMUTE_DEVELOPER_ID_P12_BASE64`
   - `TEAMUTE_DEVELOPER_ID_P12_PASSWORD`
   - `TEAMUTE_NOTARY_KEY_BASE64`
   - `TEAMUTE_NOTARY_KEY_ID`
   - `TEAMUTE_NOTARY_ISSUER_ID`

   Exporting a signing key and adding these secrets is an owner action. Never
   commit a certificate, private key, keychain, API key, or notarization
   profile.

## Release process

Set `CFBundleShortVersionString` before creating a matching `vX.Y.Z` tag. Push
that tag to release, or manually dispatch the workflow **from that same tag**
and enter the same tag value. The release workflow verifies and checks out the
tag before it accesses credentials, imports credentials into a temporary
keychain, builds a Developer ID-signed app with hardened runtime and an empty
production entitlement set, and requires a secure timestamp. It notarizes the
DMG, staples and validates its ticket, checks Gatekeeper, and only then creates
the GitHub Release.

For a local release candidate:

```sh
zsh scripts/release-dmg.sh v0.1.0
TEAMUTE_NOTARY_PROFILE=your-keychain-profile zsh scripts/notarize-dmg.sh dist/Teamute-0.1.0.dmg
```

Use a clean Mac or a quarantined download for final installation testing.

Apple requires a Developer ID signature, hardened runtime, a secure timestamp,
and no enabled `get-task-allow` entitlement for notarization. See [Apple’s
notarization guide](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) and [custom workflow
guide](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow).
