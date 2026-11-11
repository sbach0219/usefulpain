# Security and privacy

usefulpain is a local, read-only file viewer. The application contains no networking,
analytics, remote logging, updater, shell-command execution, or account system.
It accepts local file URLs only. It never modifies, moves, renames, or deletes the
files selected for viewing.

It delegates previews to Apple's Quick Look and explicitly requested external
opens to NSWorkspace. Those components and third-party preview extensions follow
their own security and network behavior. Keep macOS updated and do not preview
untrusted files merely because the app is read-only.

## Permissions

The app does not request Accessibility, Screen Recording, Full Disk Access,
Automation, camera, or microphone permissions. macOS may request ordinary folder
access for protected locations. The direct-distribution build is not App Sandbox
sandboxed; it operates with the user's normal file permissions. Do not describe
it as an isolation boundary or malware scanner.

The app does not persist selected folders or file paths between launches.
System-level recent items, Quick Look caches, or external apps may have their own
retention behavior.

## Reporting

Before public release, the maintainer should enable GitHub private vulnerability
reporting on the chosen repository. Do not post sensitive file contents, private
paths, or credentials in public issues. Until a private reporting channel is
configured, contact the repository owner privately before sharing details.

## Release security

Local builds use an ad-hoc signature. Public binary releases should use a verified
Developer ID identity, hardened runtime, and Apple notarization. Never commit
signing certificates, private keys, passwords, notarization credentials, or
personal fixture data. See `docs/RELEASING.md`.
