// swift-tools-version: 5.9
// Sparkle 2.9.1 vendored as a local binary target (MIT). Avoids SwiftPM's artifact download.
import PackageDescription

let package = Package(
    name: "Sparkle",
    platforms: [.macOS(.v10_13)],
    products: [.library(name: "Sparkle", targets: ["Sparkle"])],
    targets: [.binaryTarget(name: "Sparkle", path: "Sparkle.xcframework")]
)
