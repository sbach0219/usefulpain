import AppKit
import Quartz
import SwiftUI

struct QuickLookView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> QLPreviewView {
        let view = QLPreviewView(frame: .zero, style: .normal)!
        view.autostarts = false
        view.previewItem = url as NSURL
        context.coordinator.url = url
        return view
    }

    func updateNSView(_ view: QLPreviewView, context: Context) {
        guard context.coordinator.url != url else { return }
        view.previewItem = nil
        view.previewItem = url as NSURL
        context.coordinator.url = url
    }

    static func dismantleNSView(_ view: QLPreviewView, coordinator: Coordinator) {
        view.previewItem = nil
        view.close()
    }

    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator { var url: URL? }
}
