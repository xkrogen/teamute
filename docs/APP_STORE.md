# Mac App Store feasibility

Teamute is not ready for App Store submission yet. The Mac App Store requires
App Sandbox, while Teamute deliberately uses Accessibility APIs to inspect a
separate Teams process and CoreGraphics to send a shortcut to that process.
Those behaviors must be tested under the sandbox and reviewed against Apple's
current entitlement policy before submission; this repository does not claim
that a sandbox exception or entitlement will be granted.

The practical near-term distribution path is direct distribution: sign with a
Developer ID certificate, enable hardened runtime, package a DMG, submit it to
Apple's notarization service, and staple the resulting ticket. That route does
not remove the need for Accessibility consent, but it avoids the unproven App
Store sandbox compatibility question.

Before considering the App Store, migrate the hand-built app bundle to an
Xcode archive with a distribution signing configuration, create an App Store
Connect record, validate sandbox behavior on a clean account, add a privacy
policy/support URL and App Store metadata, and complete App Review testing.

References:

- [Preparing your app for distribution](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution)
- [App Sandbox](https://developer.apple.com/documentation/security/app-sandbox)
- [Notarizing macOS software](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
