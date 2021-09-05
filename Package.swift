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
        .package(name: "swift_helpers", url: "ssh://git.mipal.net/Users/Shared/git/swift_helpers.git", .branch("master")),
        .package(name: "MetaMachines", url: "ssh://git.mipal.net/Users/Shared/git/MetaMachines.git", .branch("filewrappers")),
        .package(name: "AttributeViews", url: "ssh://git.mipal.net/Users/Shared/git/AttributeViews.git", .branch("master")),
        .package(name: "GUUI", url: "ssh://git.mipal.net/Users/Shared/git/GUUI.git", .branch("master"))
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
