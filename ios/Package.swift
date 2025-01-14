// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "jio_webview",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "jio_webview",
            targets: ["jio_webview"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "jio_webview",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            path: "path/to/source")
    ]
)
