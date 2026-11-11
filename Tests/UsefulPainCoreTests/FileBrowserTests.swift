import XCTest
@testable import UsefulPainCore

final class FileBrowserTests: XCTestCase {
    var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: root)
    }

    func file(_ name: String) throws {
        try Data("sample".utf8).write(to: root.appendingPathComponent(name))
    }

    func testDirectoriesFirstAndNaturalSort() throws {
        try file("file10.txt")
        try file("file2.txt")
        try FileManager.default.createDirectory(at: root.appendingPathComponent("z-folder"), withIntermediateDirectories: true)
        let result = try FileBrowser.list(root)
        XCTAssertEqual(result.map(\.name), ["z-folder", "file2.txt", "file10.txt"])
        XCTAssertEqual(result[1].size, 6)
    }

    func testHiddenFilesOptIn() throws {
        try file(".secret")
        try file("visible.txt")
        XCTAssertEqual(try FileBrowser.list(root).map(\.name), ["visible.txt"])
        XCTAssertEqual(try FileBrowser.list(root, showHidden: true).count, 2)
    }

    func testRejectsFileAsDirectoryAndRemoteURL() throws {
        try file("plain.txt")
        XCTAssertThrowsError(try FileBrowser.list(root.appendingPathComponent("plain.txt")))
        XCTAssertThrowsError(try FileBrowser.validate(URL(string: "https://example.com")!))
    }

    func testMissingFileAndFolderValidation() throws {
        XCTAssertThrowsError(try FileBrowser.validate(root.appendingPathComponent("gone")))
        XCTAssertTrue(try FileBrowser.validate(root).isDirectory)
        try file("file.txt")
        XCTAssertFalse(try FileBrowser.validate(root.appendingPathComponent("file.txt")).isDirectory)
    }

    func testUnicodeAndSpacesRemainIntact() throws {
        try file("見積書 final.txt")
        XCTAssertEqual(try FileBrowser.list(root).first?.name, "見積書 final.txt")
    }

}
