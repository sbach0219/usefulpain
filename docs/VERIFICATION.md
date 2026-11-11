# Verification — 2026-11-11

## Environment

- Apple Silicon (arm64) Mac
- macOS 27.0.1 (26A434)
- Apple Swift 6.4.2
- Deployment target: macOS 14.0

## Passed

- `swift test`: **12 tests, 0 failures** (5 core + 7 pane-model tests).
- Release build and app-bundle generation on Apple Silicon.
- `lipo -archs`: arm64 only.
- `codesign --verify --deep --strict`: local ad-hoc signature valid.
- `plutil -lint`: bundle metadata valid.
- `bash -n`: both build/package scripts parse.
- Native app launch with the minimal two-pane interface.
- Standard file picker opens a synthetic text file in each pane.
- Both Quick Look text previews are visible simultaneously.
- Cancelling a replacement picker preserves both current previews.
- Closing the left preview returns its folder list and preserves the right.
- Clicking the file in that list reopens it while preserving the right.
- No Accessibility or Screen Recording prompt in the tested flows.
- Independent read-only source review; its parent-directory-permission finding
  was fixed and covered by a regression test.

## Not yet verified

- Full manual matrix in QA.md, including PDF/image/video formats, Finder
  drag-and-drop, resizing, VoiceOver, and older macOS releases.
- GitHub-hosted CI status is reported separately in the repository Actions tab:
  https://github.com/sbach0219/usefulpain/actions
- Developer ID signing, notarization, and fresh-download Gatekeeper acceptance.

The app is a working development build and the source is prepared for review and
publication. This is not a claim of a notarized, all-platform-tested public binary.
