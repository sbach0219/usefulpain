// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "usefulpain",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "usefulpain", targets: ["UsefulPainApp"])],
    targets: [
        .target(name: "UsefulPainCore"),
        .executableTarget(name: "UsefulPainApp", dependencies: ["UsefulPainCore"]),
        .testTarget(name: "UsefulPainCoreTests", dependencies: ["UsefulPainCore"]),
        .testTarget(name: "UsefulPainAppTests", dependencies: ["UsefulPainApp"])
    ]
)
