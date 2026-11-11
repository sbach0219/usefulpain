import AppKit
import SwiftUI
import UsefulPainCore

@MainActor
final class PaneModel: ObservableObject {
    @Published private(set) var directory: URL?
    @Published private(set) var entries: [FileEntry] = []
    @Published private(set) var previewURL: URL?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    private let listDirectory: @Sendable (URL) throws -> [FileEntry]
    private var folderError: String?
    private var revision = 0
    private var loadTask: Task<Void, Never>?

    init(listDirectory: @escaping @Sendable (URL) throws -> [FileEntry] = { try FileBrowser.list($0) }) {
        self.listDirectory = listDirectory
    }

    func chooseFolder() { choose(directories: true) }
    func chooseFile() { choose(directories: false) }

    private func choose(directories: Bool) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = directories
        panel.canChooseFiles = !directories
        panel.allowsMultipleSelection = false
        panel.directoryURL = directory
        panel.prompt = "選ぶ"
        if let window = NSApp.keyWindow {
            panel.beginSheetModal(for: window) { [weak self] response in
                if response == .OK, let url = panel.url { self?.open(url) }
            }
        } else {
            panel.begin { [weak self] response in
                if response == .OK, let url = panel.url { self?.open(url) }
            }
        }
    }

    func open(_ url: URL) { load(url: url, preservePreview: false) }

    func refresh() {
        guard let directory, !isLoading else { return }
        load(url: directory, preservePreview: true)
    }

    func closeFile() {
        revision += 1
        loadTask?.cancel()
        isLoading = false
        previewURL = nil
        errorMessage = folderError
    }

    func back() {
        if previewURL != nil {
            closeFile()
        } else if let directory {
            let parent = directory.deletingLastPathComponent()
            if parent != directory { open(parent) }
        }
    }

    func openExternally() {
        guard let previewURL else { return }
        NSWorkspace.shared.open(previewURL)
    }

    private func load(url: URL, preservePreview: Bool) {
        revision += 1
        let request = revision
        let listDirectory = self.listDirectory
        loadTask?.cancel()
        isLoading = true
        errorMessage = nil
        loadTask = Task { [weak self] in
            do {
                let result = try await Task.detached(priority: .userInitiated) {
                    let target = try FileBrowser.validate(url)
                    let folder = target.isDirectory ? target.url : target.url.deletingLastPathComponent()
                    if target.isDirectory {
                        return (folder, try listDirectory(folder), Optional<URL>.none, Optional<String>.none)
                    }
                    // Opening a readable file must not require permission to list its parent.
                    do {
                        return (folder, try listDirectory(folder), Optional(target.url), Optional<String>.none)
                    } catch {
                        return (folder, [FileEntry](), Optional(target.url), Optional("フォルダの一覧を読み込めません。\n" + error.localizedDescription))
                    }
                }.value
                guard let self, !Task.isCancelled, request == self.revision else { return }
                self.directory = result.0
                self.entries = result.1
                self.folderError = result.3
                self.errorMessage = result.3
                if !preservePreview { self.previewURL = result.2 }
                else if let preview = self.previewURL, !FileManager.default.fileExists(atPath: preview.path) {
                    self.previewURL = nil
                    self.errorMessage = "ファイルが移動または削除されました。"
                }
                self.isLoading = false
            } catch {
                guard let self, !Task.isCancelled, request == self.revision else { return }
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
