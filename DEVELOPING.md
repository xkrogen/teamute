# Developing Teamute

This guide is for contributors and release maintainers. For normal
installation, use the [README](README.md).

## Local build and installation

Teamute’s local build is signed with an available **Apple Development**
identity so macOS can retain its Accessibility trust for the installed app.
The build script discovers that identity, or you can supply
`TEAMUTE_SIGNING_IDENTITY` explicitly.

```sh
./build-teamute.sh
./install-teamute.sh
open /Applications/Teamute.app
```

`install-teamute.sh` stops only the running Teamute executable at the installed
path, validates the bundle identity, and replaces `/Applications/Teamute.app`.
It will not replace a different application.

## Verification and live-call diagnostics

Run the non-mutating checks after a local install:

```sh
/Applications/Teamute.app/Contents/MacOS/Teamute --self-test
/Applications/Teamute.app/Contents/MacOS/Teamute --probe
```

`--verify-camera` and `--verify-ptt` deliberately control and restore a live
Teams call. Run them only on a call you are authorized to control and confirm
the starting state before use. `--render-settings` writes a local settings-view
render for UI review.

## Contributing

Keep changes focused and private by design. Do not add Teams credentials,
network integrations, private APIs, global keyboard injection, recordings, or
system-microphone control. Before opening a pull request, run the local build
and `--self-test`, and include the validation performed plus any macOS or Teams
limitation. See [CONTRIBUTING.md](CONTRIBUTING.md) for the short contribution
policy.

## GitHub release distribution

Pull requests and branch pushes build an ad-hoc-signed test DMG artifact. It
is not Developer ID signed and is not notarized.

To publish a versioned public release:

1. Set `CFBundleShortVersionString` in `Teamute/Info.plist`.
2. Commit and push that version, then create a matching `vX.Y.Z` tag.
3. Create and **publish** the GitHub Release for that exact tag. Publishing
   triggers the workflow, which verifies the tag/version match, builds
   `Teamute-X.Y.Z-macOS-unsigned.dmg`, creates its SHA-256 sidecar, and attaches
   both to the existing release.
4. Download both release assets and, in their folder, run
   `shasum -a 256 -c Teamute-X.Y.Z-macOS-unsigned.dmg.sha256`.

No Apple account, certificate, notarization credential, or repository secret
is needed. The release DMG has an ad-hoc local signature only: it is not
Developer ID signed and not notarized. Keep that distinction in release notes
and user-facing documentation.

For a retry, use **Actions → Build DMG → Run workflow**, select the exact tag
as the workflow ref, and enter that same tag. The workflow replaces the DMG
and checksum assets. Do not move or rewrite an existing release tag.

See [docs/distribution.md](docs/distribution.md) for a concise public
distribution summary.
