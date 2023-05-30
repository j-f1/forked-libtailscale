import PackagePlugin
import Foundation

@main
struct BuildPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard var paths = ProcessInfo.processInfo.environment["PATH"]?.split(separator: ":").map(String.init) else {
            print("error: PATH variable not set")
            exit(1)
        }
        paths.append("/usr/local/bin")
        paths.append("/opt/homebrew/bin")

        guard let goFolder = try paths.first(where: {
            try FileManager.default.contentsOfDirectory(atPath: $0).contains("go")
        }) else {
            print("error: Could not find 'go' in PATH:", terminator: "")
            print("\(([""] + paths).joined(separator: "\n- "))")
            exit(1)
        }

        let GOCACHE = context.pluginWorkDirectory.appending(["go-cache"]).string
        let GOMODCACHE = context.pluginWorkDirectory.appending(["go-mod-cache"]).string
        let outputDir = context.pluginWorkDirectory.appending(["out"])

        if !FileManager.default.fileExists(atPath: GOMODCACHE) {
            print("error: Need to run `go mod download` separately first:")
            print("")
            print("$ GOCACHE=\(GOCACHE) GOMODCACHE=\(GOMODCACHE) \(goFolder)/go mod download")
            print("")
            print("This is because the plugin system does not allow the network access needed to download dependencies.")
            exit(1)
        }
        return [
            .buildCommand(
                displayName: "Go Build",
                executable: Path(goFolder).appending(["go"]),
                arguments: ["build", "-buildmode=c-archive", "-o", outputDir.string],
                environment: [
                    "GOCACHE": GOCACHE,
                    "GOMODCACHE": GOMODCACHE,
                ],
                inputFiles: ["go.mod", "go.sum", "tailscale.h", "tailscale.c", "tailscale.go"].map { context.package.directory.appending([$0]) },
                outputFiles: ["libtailscale.h", "libtailscale.a"].map { outputDir.appending([$0]) }
            )
        ]
    }
}
