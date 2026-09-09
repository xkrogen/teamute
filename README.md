# Teamute

Teamute is a compact native macOS menu-bar companion for Microsoft Teams. It
shows a confirmed Teams call state and toggles microphone or camera without
activating Teams or changing the system microphone.

## Privacy-first control

Teamute reads the visible Teams meeting toolbar through macOS Accessibility
and sends Teams' advertised in-app shortcuts only to the detected Teams PID.
It uses no network service, Teams token, Apple Events, private API, screen
recording, system-microphone control, or global keyboard injection. Each
transition is read back from Teams before it is shown as successful.

## Install

```sh
./build-teamute.sh
./install-teamute.sh
open /Applications/Teamute.app
```

Allow **Teamute** in **System Settings → Privacy & Security → Accessibility**.
The first run requests the permission, and Settings shows the current status.

Defaults: Command-Shift-A toggles audio and Command-Shift-Z toggles video.
Push-to-talk is optional and unassigned by default; it restores mute only for
the same recognized call.

## Verify

```sh
/Applications/Teamute.app/Contents/MacOS/Teamute --self-test
/Applications/Teamute.app/Contents/MacOS/Teamute --probe
```

`--verify-camera` and `--verify-ptt` deliberately toggle and restore a live
Teams call. Run them only when authorized to control that call.

## Development and release

See [CONTRIBUTING.md](CONTRIBUTING.md). GitHub Actions builds an unsigned DMG
artifact. Production release signing and notarization are separate macOS steps.

## License

[MIT](LICENSE)
