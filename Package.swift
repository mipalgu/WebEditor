// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WebEditor",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "MachineViews", targets: ["MachineViews"]),
        .executable(name: "WebEditor", targets: ["WebEditor"])
    ],
    dependencies: [
        .package(name: "swift_helpers", url: "https://github.com/mipalgu/swift_helpers.git", .branch("main")),
        .package(name: "MetaMachines", url: "git@github.com:mipalgu/MetaMachines.git", .branch("workflows")),
        .package(name: "AttributeViews", url: "git@github.com:mipalgu/AttributeViews.git", .branch("develop")),
        .package(name: "GUUI", url: "git@github.com:mipalgu/GUUI.git", .branch("develop"))
    ],
    targets: [
        .target(name: "Utilities", dependencies: ["MetaMachines", "AttributeViews"]),
        .target(name: "Transformations", dependencies: ["GUUI"]),
        .target(
            name: "MachineViews",
            dependencies: ["MetaMachines", "AttributeViews", "Utilities", "Transformations", "GUUI", "swift_helpers"],
            resources: [.copy("Resources/Assets.xcassets")]
        ),
        .target(
            name: "WebEditor",
            dependencies: [
                "MetaMachines",
                "MachineViews"
            ]),
        .testTarget(
            name: "WebEditorTests",
            dependencies: ["WebEditor"]),
    ]
)
