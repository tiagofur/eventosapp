// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SolennixNetwork",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SolennixNetwork", targets: ["SolennixNetwork"])
    ],
    dependencies: [
        .package(path: "../SolennixCore")
    ],
    targets: [
        .target(name: "SolennixNetwork", dependencies: ["SolennixCore"])
    ]
)
