# Contributing

Teamute is a small native macOS utility. Keep changes focused, private by
design, and compatible with the public AppKit, Accessibility, Carbon, and
CoreGraphics APIs already used by the app.

Before opening a pull request, run `./build-teamute.sh` and the app's
`--self-test` command. Do not add Teams credentials, network integrations,
private APIs, global event injection, or recordings to the project. Test any
Teams toggle against a call you are authorized to control and restore its
initial state.

Please include a concise description, validation performed, and any macOS or
Teams-version limitation in your pull request.
