// swift-tools-version:5.3
import PackageDescription

let ui: [Package.Dependency] = [.package(name: "Tokamak", url: "https://github.com/TokamakUI/Tokamak", from: "0.5.1")]
let products: [Target.Dependency] = [.product(name: "TokamakShim", package: "Tokamak")]

let package = Package(
    name: "WebEditor",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "MachineViews", targets: ["MachineViews"]),
        .executable(name: "WebEditor", targets: ["WebEditor"])
    ],
    dependencies: ui + [
        .package(name: "swift_helpers", url: "https://github.com/mipalgu/swift_helpers.git", .branch("main")),
        .package(name: "MetaMachines", url: "git@github.com:mipalgu/MetaMachines.git", .branch("main")),
        .package(name: "AttributeViews", url: "git@github.com:mipalgu/AttributeViews.git", .branch("main")),
        .package(name: "GUUI", url: "git@github.com:mipalgu/GUUI.git", .branch("main"))
    ],
    targets: [
        .target(name: "Utilities", dependencies: products + ["MetaMachines", "AttributeViews"]),
        .target(name: "Transformations", dependencies: products + ["GUUI"]),
        .target(
            name: "MachineViews",
            dependencies: products + ["MetaMachines", "AttributeViews", "Utilities", "Transformations", "GUUI", "swift_helpers"],
            resources: [.copy("Resources/Assets.xcassets")]
        ),
        .target(
            name: "WebEditor",
            dependencies: products + [
                "MetaMachines",
                "MachineViews"
            ]),
        .testTarget(
            name: "WebEditorTests",
            dependencies: ["WebEditor"]),
    ]
)
