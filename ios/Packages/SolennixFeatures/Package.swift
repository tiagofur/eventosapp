// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SolennixFeatures",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SolennixFeatures", targets: ["SolennixFeatures"])
    ],
    dependencies: [
        .package(path: "../SolennixCore"),
        .package(path: "../SolennixNetwork"),
        .package(path: "../SolennixDesign")
    ],
    targets: [
        .target(name: "SolennixFeatures",
                dependencies: ["SolennixCore", "SolennixNetwork", "SolennixDesign"])
    ]
)
