// swift-tools-version:5.3
import PackageDescription

#if arch(wasm32)
let ui: [Package.Dependency] = [.package(name: "Tokamak", url: "https://github.com/TokamakUI/Tokamak", from: "0.5.1")]
let products: [Target.Dependency] = [.product(name: "TokamakShim", package: "Tokamak")]
#else
let ui: [Package.Dependency] = []
let products: [Target.Dependency] = []
#endif

let package = Package(
    name: "WebEditor",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "WebEditor", targets: ["WebEditor"])
    ],
    dependencies: ui + [
        .package(url: "ssh://git.mipal.net/Users/Shared/git/Machines.git",
            .branch("meta")
        )
    ],
    targets: [
        .target(name: "Utilities", dependencies: products + ["Machines"]),
        .target(name: "Transformations", dependencies: products),
        .target(name: "AttributeViews", dependencies: products + ["Machines", "Utilities"]),
        .target(name: "MachineViews", dependencies: products + ["Machines", "AttributeViews", "Utilities", "Transformations"]),
        .target(
            name: "WebEditor",
            dependencies: products + [
                "Machines",
                "MachineViews"
            ]),
        .testTarget(
            name: "WebEditorTests",
            dependencies: ["WebEditor"]),
    ]
)
