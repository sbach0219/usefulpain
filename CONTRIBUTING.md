# Contributing

Keep usefulpain small: two independent panes, file selection, and previews.

1. Use an Apple Silicon Mac, macOS 14+, and Swift 5.9+.
2. Keep changes focused and add tests for the affected behavior.
3. Run `swift test` and `./scripts/build-app.sh`.
4. Follow `docs/QA.md`, particularly replacing/closing one pane, Cancel, missing
   files, and rapid repeated actions.
5. Describe the behavior and actual verification in the pull request. Use only
   synthetic data in screenshots and test fixtures.

Avoid new dependencies or settings. Do not add file mutation, telemetry,
persistent permissions, or background services without a design discussion.
Use accessible labels for icon-only controls.

Contributions are made under the project’s MIT license.
Do not contribute code or assets you are not entitled to share.
