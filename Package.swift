// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "libtailscale",
    products: [
        .library(name: "Tailscale", targets: ["Tailscale"])
    ],
    targets: [
        .target(
            name: "Tailscale",
            path: "swift/src",
            publicHeadersPath: "out",
            plugins: [.plugin(name: "GoBuild")]
        ),
        .plugin(
            name: "GoBuild",
            capability: .buildTool(),
            path: "swift/build-tool"
        )
    ]
)
