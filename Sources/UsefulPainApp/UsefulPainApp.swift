import SwiftUI

@main
struct UsefulPainApp: App {
    var body: some Scene {
        Window("usefulpain", id: "main") {
            ContentView()
        }
        .defaultSize(width: 1040, height: 720)
        .windowResizability(.contentMinSize)
    }
}
