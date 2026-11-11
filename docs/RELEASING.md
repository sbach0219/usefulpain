# Publication and release checklist

## Source release

Before creating a public GitHub repository:

- [x] Source repository: `sbach0219/usefulpain`, public (owner approved).
- [x] Name: usefulpain. License: MIT. Copyright: Soshi Shibata (owner approved).
- [ ] Confirm the production bundle ID. `app.usefulpain.desktop` is a development
      identifier and does not assert ownership of a domain or trademark.
- [ ] Run `swift test` and `./scripts/build-app.sh` on Apple Silicon.
- [ ] Complete the manual checks in `QA.md` on the supported macOS versions.
- [ ] Ensure no secrets, local data, `.build`, or `dist` are included in source.
- [ ] Enable private vulnerability reporting and configure repository metadata.
- [ ] Review the pinned GitHub Actions versions and verify CI on the exact commit.

No GitHub repository has been created or pushed by these build scripts.

## Build a local test archive

```sh
./scripts/package-release.sh
```

This creates `dist/usefulpain-0.1.0-arm64.zip` and its SHA-256 file. The default ad-hoc
signature is appropriate for local development, not a notarized public release.
Do not advertise this file as notarized or as fully tested on all supported OS
versions.

## Public binary distribution

A maintainer with the appropriate Apple Developer membership must configure a
Developer ID Application certificate in their own Keychain. Never put private
keys, passwords, or authentication tokens in this repository.

1. Set the final bundle ID and version in `Resources/Info.plist`.
2. Run tests and the full manual QA matrix.
3. Build and package with the maintainer's signing identity:

   ```sh
   CODE_SIGN_IDENTITY='Developer ID Application: YOUR NAME (TEAMID)' ./scripts/package-release.sh
   ```

4. Submit the resulting ZIP with `xcrun notarytool submit`, using credentials
   stored securely in the maintainer's Keychain. Read the Apple notarization
   result and logs. Do not publish until it is accepted.
5. Staple the ticket to `dist/usefulpain.app` using `xcrun stapler staple`, then run
   `xcrun stapler validate` and `spctl --assess --type execute --verbose=2`.
6. Re-create the ZIP from the stapled app with `ditto`, then generate a new
   SHA-256 file. Re-running the build script at this step would rebuild the app
   and discard the stapled bundle, so repackage without rebuilding:

   ```sh
   ditto -c -k --sequesterRsrc --keepParent dist/usefulpain.app dist/usefulpain-0.1.0-arm64.zip
   shasum -a 256 dist/usefulpain-0.1.0-arm64.zip > dist/usefulpain-0.1.0-arm64.zip.sha256
   ```

7. Verify a fresh download on another Apple Silicon Mac with normal Gatekeeper
   settings. Never ask users to disable Gatekeeper or SIP.
8. Publish a reviewed tag and release notes with the app archive, checksum,
   minimum OS version, tested versions, and known issues.

The CI workflow tests/builds only. It does not publish, sign with Developer ID,
notarize, create tags, or create releases automatically.
