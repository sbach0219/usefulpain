import Foundation

public struct FileEntry: Identifiable, Hashable, Sendable {
    public var id: URL { url }
    public let url: URL
    public let name: String
    public let isDirectory: Bool
    public let size: Int64?

    public init(url: URL, name: String, isDirectory: Bool, size: Int64? = nil) {
        self.url = url
        self.name = name
        self.isDirectory = isDirectory
        self.size = size
    }
}

public enum BrowserError: LocalizedError {
    case notDirectory
    case notFileURL
    case missingFile

    public var errorDescription: String? {
        switch self {
        case .notDirectory: return "フォルダを開けません。存在するフォルダを選んでください。"
        case .notFileURL: return "この場所は開けません。Finderのファイルかフォルダを選んでください。"
        case .missingFile: return "ファイルが見つかりません。移動・削除されていないか確認してください。"
        }
    }
}

public enum FileBrowser {
    public static func list(_ directory: URL, showHidden: Bool = false) throws -> [FileEntry] {
        guard directory.isFileURL else { throw BrowserError.notFileURL }
        let values = try directory.resourceValues(forKeys: [.isDirectoryKey])
        guard values.isDirectory == true else { throw BrowserError.notDirectory }
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .isPackageKey, .fileSizeKey]
        let options: FileManager.DirectoryEnumerationOptions = showHidden ? [] : [.skipsHiddenFiles]
        let urls = try FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: Array(keys), options: options
        )
        return urls.map { url in
            let info = try? url.resourceValues(forKeys: keys)
            return FileEntry(
                url: url.standardizedFileURL,
                name: url.lastPathComponent,
                isDirectory: info?.isDirectory == true && info?.isPackage != true,
                size: info?.fileSize.map(Int64.init)
            )
        }.sorted {
            if $0.isDirectory != $1.isDirectory { return $0.isDirectory }
            let order = $0.name.localizedStandardCompare($1.name)
            return order == .orderedSame ? $0.url.path < $1.url.path : order == .orderedAscending
        }
    }

    public static func validate(_ url: URL) throws -> (url: URL, isDirectory: Bool) {
        guard url.isFileURL else { throw BrowserError.notFileURL }
        let normalized = url.standardizedFileURL
        var directory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: normalized.path, isDirectory: &directory) else {
            throw BrowserError.missingFile
        }
        let package = try? normalized.resourceValues(forKeys: [.isPackageKey]).isPackage
        return (normalized, directory.boolValue && package != true)
    }
}
