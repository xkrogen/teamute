# GitHub distribution (unsigned)

Teamute’s public GitHub-release DMGs are labeled **unsigned** because they are
not Developer ID signed and are not notarized. They contain only an ad-hoc
local signature so Apple-silicon Macs can execute them; it establishes no
verified developer identity. This is a zero-cost distribution path, not a
trust guarantee. Download only from this repository and make your own decision
before overriding a macOS warning.

## Publishing a release

Set `CFBundleShortVersionString`, then create a GitHub Release whose tag exactly
matches it as `vX.Y.Z`. Publishing that release starts the release workflow; it
checks out that tag, verifies the tag/version match, builds
`Teamute-X.Y.Z-macOS-unsigned.dmg`, creates its SHA-256 sidecar, and uploads
both to the existing release. No Apple account, certificate, notarization
credential, or repository secret is used.

For a draft, publish it only when ready to start the build. Re-publishing an
already published release does not re-run the workflow. A maintainer can also
run the workflow manually **from the exact existing tag** and enter that same
tag; it will attach or replace the two assets.

## Opening a download

1. Download the DMG and its `.sha256` file from the GitHub Release, then run
   `shasum -a 256 -c Teamute-X.Y.Z-macOS-unsigned.dmg.sha256` in that folder.
2. If macOS blocks the app, verify that you trust the repository and download.
   Then use **System Settings → Privacy & Security → Open Anyway** and confirm
   Open. Apple documents this flow in [Safely open apps on your
   Mac](https://support.apple.com/en-la/102445).

Do not disable Gatekeeper or remove quarantine attributes to open Teamute.
