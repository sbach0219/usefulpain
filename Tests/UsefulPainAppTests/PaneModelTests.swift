import XCTest
@testable import UsefulPainApp

@MainActor
final class PaneModelTests: XCTestCase {
    private func fixture() throws -> (URL, URL, URL) {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let a = folder.appendingPathComponent("A.txt")
        let b = folder.appendingPathComponent("B.txt")
        try Data("A".utf8).write(to: a)
        try Data("B".utf8).write(to: b)
        return (folder, a, b)
    }

    private func settle(_ pane: PaneModel) async throws {
        for _ in 0..<200 {
            if !pane.isLoading { return }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        XCTFail("Pane loading timed out")
    }

    func testReplaceAndClosePreserveOtherPane() async throws {
        let (folder, a, b) = try fixture()
        defer { try? FileManager.default.removeItem(at: folder) }
        let left = PaneModel(), right = PaneModel()
        left.open(a)
        right.open(b)
        try await settle(left)
        try await settle(right)
        XCTAssertEqual(left.previewURL, a)
        XCTAssertEqual(right.previewURL, b)
        left.open(b)
        try await settle(left)
        XCTAssertEqual(left.previewURL, b)
        left.closeFile()
        XCTAssertNil(left.previewURL)
        XCTAssertEqual(left.directory, folder)
        XCTAssertEqual(left.entries.count, 2)
        XCTAssertEqual(right.previewURL, b)
    }

    func testFailedReplacementKeepsCurrentPreview() async throws {
        let (folder, a, _) = try fixture()
        defer { try? FileManager.default.removeItem(at: folder) }
        let pane = PaneModel()
        pane.open(a)
        try await settle(pane)
        pane.open(folder.appendingPathComponent("missing.txt"))
        try await settle(pane)
        XCTAssertEqual(pane.previewURL, a)
        XCTAssertNotNil(pane.errorMessage)
    }

    func testCloseCancelsPendingOpen() async throws {
        let (folder, a, b) = try fixture()
        defer { try? FileManager.default.removeItem(at: folder) }
        let pane = PaneModel()
        pane.open(a)
        try await settle(pane)
        pane.open(b)
        pane.closeFile()
        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNil(pane.previewURL)
        XCTAssertFalse(pane.isLoading)
        XCTAssertEqual(pane.directory, folder)
    }

    func testLatestOpenWins() async throws {
        let (folder, a, b) = try fixture()
        defer { try? FileManager.default.removeItem(at: folder) }
        let pane = PaneModel()
        pane.open(a)
        pane.open(b)
        try await settle(pane)
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(pane.previewURL, b)
    }

    func testRefreshClearsDeletedPreview() async throws {
        let (folder, a, _) = try fixture()
        defer { try? FileManager.default.removeItem(at: folder) }
        let pane = PaneModel()
        pane.open(a)
        try await settle(pane)
        try FileManager.default.removeItem(at: a)
        pane.refresh()
        try await settle(pane)
        XCTAssertNil(pane.previewURL)
        XCTAssertNotNil(pane.errorMessage)
    }

    func testRefreshDoesNotOverridePendingReplacement() async throws {
        let (folder, a, b) = try fixture()
        defer { try? FileManager.default.removeItem(at: folder) }
        let pane = PaneModel()
        pane.open(a)
        try await settle(pane)
        pane.open(b)
        pane.refresh()
        try await settle(pane)
        XCTAssertEqual(pane.previewURL, b)
    }

    func testDirectFileCanOpenWhenParentCannotBeListed() async throws {
        let (folder, a, _) = try fixture()
        defer { try? FileManager.default.removeItem(at: folder) }
        let pane = PaneModel(listDirectory: { _ in throw CocoaError(.fileReadNoPermission) })
        pane.open(a)
        try await settle(pane)
        XCTAssertEqual(pane.previewURL, a)
        XCTAssertNotNil(pane.errorMessage)
        pane.closeFile()
        XCTAssertNil(pane.previewURL)
        XCTAssertNotNil(pane.errorMessage)
    }
}
