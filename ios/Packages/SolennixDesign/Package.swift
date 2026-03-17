// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SolennixDesign",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SolennixDesign", targets: ["SolennixDesign"])
    ],
    targets: [
        .target(name: "SolennixDesign")
    ]
)
