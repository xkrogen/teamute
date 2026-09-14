# Teamute

Teamute is a compact native macOS menu-bar companion for Microsoft Teams. It
shows confirmed call state and lets you control microphone and camera without
activating Teams or changing the system microphone.

## Install Teamute

1. Download the DMG from the [latest Teamute release](https://github.com/xkrogen/teamute/releases/latest).
2. Open the downloaded DMG in Finder. Copy, or drag, `Teamute.app` to
   **Applications** (the Applications item in Finder’s sidebar is a convenient
   destination).
3. Open **Teamute** from Applications.
4. Teamute needs Accessibility permission: open **System Settings → Privacy &
   Security → Accessibility** and enable **Teamute**. Settings inside Teamute
   shows whether the permission is enabled.

### macOS security warning

The release DMG has only an ad-hoc local signature: it is not Developer ID
signed and is not notarized by Apple. Download it only if you trust this
repository. If macOS blocks Teamute, open **System Settings → Privacy &
Security**, choose **Open Anyway** for Teamute, then confirm Open. Apple
documents this process in [Safely open apps on your Mac](https://support.apple.com/en-la/102445).

Each release also includes a `.sha256` file for people who want to verify the
download before opening it. Do not disable Gatekeeper or remove quarantine
attributes to install Teamute.

## Using Teamute

- The paired menu-bar controls independently toggle audio and video; their
  shared context menu shows detailed call and permission status.
- Default shortcuts are Command-Shift-A for audio and Command-Shift-Z for
  video. Push-to-talk is optional, unassigned by default, and restores mute
  only for the same recognized call.
- Settings lets you change shortcuts, configure launch at login, and check
  Accessibility permission.

## Privacy-first control

Teamute reads the visible Teams meeting toolbar through macOS Accessibility
and sends Teams’ advertised in-app shortcuts only to the detected Teams PID.
It uses no network service, Teams token, Apple Events, private API, screen
recording, system-microphone control, or global keyboard injection. Each
transition is read back from Teams before it is shown as successful.
When Teams exposes one compact call popup beside one full-size meeting-control
window, Teamute uses the popup as the authoritative state reader; additional
eligible meeting-control windows remain unavailable rather than guessed.

## Development

Build instructions, diagnostics, contribution guidance, and GitHub-release
maintenance are in [DEVELOPING.md](DEVELOPING.md).

## License

[MIT](LICENSE)
