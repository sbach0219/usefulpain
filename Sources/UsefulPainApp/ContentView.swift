import AppKit
import SwiftUI
import UsefulPainCore

struct ContentView: View {
    @StateObject private var left = PaneModel()
    @StateObject private var right = PaneModel()

    var body: some View {
        HSplitView {
            PaneView(model: left, label: "左").frame(minWidth: 290, maxWidth: .infinity)
            PaneView(model: right, label: "右").frame(minWidth: 290, maxWidth: .infinity)
        }
        .frame(minWidth: 600, minHeight: 400)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            left.refresh()
            right.refresh()
        }
    }
}

private struct PaneView: View {
    @ObservedObject var model: PaneModel
    let label: String
    @State private var dropTargeted = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                if model.directory != nil {
                    Button { model.back() } label: { Image(systemName: model.previewURL == nil ? "chevron.left" : "xmark") }
                        .buttonStyle(.borderless)
                        .disabled(model.previewURL == nil && model.directory?.path == "/")
                        .help(model.previewURL == nil ? "親フォルダ" : "ファイルを閉じて一覧に戻る")
                        .accessibilityLabel("\(label): \(model.previewURL == nil ? "親フォルダへ" : "ファイルを閉じる")")
                }
                Text(model.previewURL?.lastPathComponent ?? model.directory?.lastPathComponent ?? "")
                    .font(.system(size: 12)).lineLimit(1).truncationMode(.middle)
                    .help((model.previewURL ?? model.directory)?.path ?? "")
                    .contextMenu {
                        if model.previewURL != nil {
                            Button("既定のアプリで開く") { model.openExternally() }
                        }
                    }
                Spacer(minLength: 0)
                if model.isLoading { ProgressView().controlSize(.small) }
                Button("フォルダ") { model.chooseFolder() }
                    .help("\(label)のフォルダを選ぶ")
                Button("ファイル") { model.chooseFile() }
                    .help("\(label)のファイルを選ぶ")
            }.padding(10)
            Divider()
            if let error = model.errorMessage {
                HStack(alignment: .top) {
                    Text(error).font(.callout).foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                    Button { model.errorMessage = nil } label: { Image(systemName: "xmark") }
                        .buttonStyle(.plain).accessibilityLabel("エラーを閉じる")
                }.padding(12)
            }
            if let url = model.previewURL {
                QuickLookView(url: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contextMenu {
                        Button("既定のアプリで開く") { model.openExternally() }
                        Button("一覧に戻る") { model.back() }
                    }
            } else if model.directory != nil {
                if model.entries.isEmpty {
                    Text("ファイルがありません")
                        .font(.callout).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(model.entries) { entry in
                                Button { model.open(entry.url) } label: {
                                    HStack(spacing: 8) {
                                        Image(nsImage: NSWorkspace.shared.icon(forFile: entry.url.path))
                                            .resizable().frame(width: 18, height: 18)
                                        Text(entry.name).lineLimit(1).truncationMode(.middle)
                                        Spacer(minLength: 4)
                                        if entry.isDirectory {
                                            Image(systemName: "chevron.right")
                                                .font(.caption2).foregroundStyle(.tertiary)
                                        }
                                    }.padding(.horizontal, 12).padding(.vertical, 8)
                                        .contentShape(Rectangle())
                                }.buttonStyle(.plain)
                                    .accessibilityLabel("\(entry.name)を\(entry.isDirectory ? "開く" : "表示")")
                            }
                        }.padding(.vertical, 4)
                    }.accessibilityLabel("\(label)のファイル一覧")
                }
            } else {
                Text("フォルダかファイルを選ぶ。\nFinderからドロップでも。")
                    .font(.callout).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center).lineSpacing(5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .overlay { Rectangle().stroke(dropTargeted ? Color.accentColor : .clear, lineWidth: 2) }
        .dropDestination(for: URL.self) { urls, _ in
            guard let first = urls.first, first.isFileURL else { return false }
            model.open(first)
            return true
        } isTargeted: { dropTargeted = $0 }
    }
}
