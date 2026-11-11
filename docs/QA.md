# Quality checks

## Automated

`swift test` checks natural sort, folders-first ordering, hidden files, Unicode,
invalid or missing paths, file/folder validation, replacing one pane without
changing the other, closing during a pending load, failed replacement preserving
the existing preview, last-request-wins behavior, and deleted-file refresh.

`./scripts/build-app.sh` checks release compilation, bundle metadata, icon
creation, arm64-only architecture, and the local code signature.

These do not prove every Quick Look format or UI flow. Record actual results in
`VERIFICATION.md` and leave untested checks clearly marked.

## Manual checks

Use synthetic files. Cover both current macOS and macOS 14 before claiming broad
OS support.

- [ ] Cold launch: only two panes and folder/file buttons.
- [ ] Choose a folder, click a file, and return to the list with ×.
- [ ] Choose a file directly in each pane; both previews remain visible.
- [ ] Replace one file, then cancel another replacement; the other pane stays put.
- [ ] Repeatedly close and reopen one pane without disturbing the other.
- [ ] Navigate into a folder and back to its parent; handle root and empty folders.
- [ ] PDF, image, text, and unsupported Quick Look formats.
- [ ] Finder drag-and-drop to both panes, including while already previewing.
- [ ] Missing files, permission errors, and repeated selection during loading.
- [ ] Resize the window and central divider; minimum size remains usable.
- [ ] Keyboard access to buttons, VoiceOver labels, light/dark appearance.
- [ ] Close/reopen the window and relaunch without crashes.
- [ ] No Accessibility or Screen Recording prompt.
