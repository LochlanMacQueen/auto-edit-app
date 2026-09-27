import AppKit
import Foundation

/// Runs the auto-edit server (Python, bundled under Resources/autoedit-runtime) next to the
/// editor. One process serves the agent's MCP endpoint and the Review/Setup/Phone dashboard
/// on 127.0.0.1:4747. If something already answers there (a dev server or the launchd agent
/// from install.sh), the app reuses it instead of starting a second one.
@MainActor
final class AutoEditSidecar {
    static let shared = AutoEditSidecar()
    nonisolated static let port = 4747
    nonisolated static var baseURL: URL { URL(string: "http://127.0.0.1:\(port)")! }

    private var process: Process?
    private(set) var isExternal = false

    private init() {}

    var runtimeURL: URL? {
        Bundle.main.resourceURL?.appendingPathComponent("autoedit-runtime", isDirectory: true)
    }

    func start() {
        Task { @MainActor in
            if await Self.isUp() {
                isExternal = true
                Log.mcp.notice("auto-edit: reusing server already on :\(Self.port)")
                return
            }
            launch()
        }
    }

    private func launch() {
        guard let runtime = runtimeURL else { return }
        let python = runtime.appendingPathComponent("python/bin/python3.12")
        let appDir = runtime.appendingPathComponent("app", isDirectory: true)
        guard FileManager.default.isExecutableFile(atPath: python.path),
              FileManager.default.fileExists(atPath: appDir.appendingPathComponent("autoedit").path)
        else {
            Log.mcp.warning("auto-edit: runtime missing at \(runtime.path); start the server manually")
            return
        }
        let home = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("AutoEdit", isDirectory: true)
        let logs = home.appendingPathComponent("logs", isDirectory: true)
        try? FileManager.default.createDirectory(at: logs, withIntermediateDirectories: true)
        let p = Process()
        p.executableURL = python
        p.arguments = ["-u", "-m", "autoedit", "serve"]
        p.currentDirectoryURL = appDir
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = runtime.appendingPathComponent("bin").path + ":/opt/homebrew/bin:/usr/local/bin:" + (env["PATH"] ?? "/usr/bin:/bin")
        env["AUTOEDIT_HOME"] = home.path
        env["AUTOEDIT_PORT"] = String(Self.port)
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        p.environment = env
        if let fh = try? FileHandle(forWritingTo: logs.appendingPathComponent("sidecar.log")) {
            fh.seekToEndOfFile(); p.standardOutput = fh; p.standardError = fh
        } else {
            FileManager.default.createFile(atPath: logs.appendingPathComponent("sidecar.log").path, contents: nil)
            if let fh = try? FileHandle(forWritingTo: logs.appendingPathComponent("sidecar.log")) { p.standardOutput = fh; p.standardError = fh }
        }
        do {
            try p.run()
            process = p
            Log.mcp.notice("auto-edit: sidecar started pid=\(p.processIdentifier)")
        } catch {
            Log.mcp.error("auto-edit: sidecar failed to start: \(error.localizedDescription)")
        }
    }

    func stop() {
        guard let p = process, p.isRunning else { return }
        p.terminate()
        process = nil
        let pid = p.processIdentifier
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 3) {
            if p.isRunning { kill(pid, SIGKILL) }       // never leave the server running after quit
        }
    }

    nonisolated static func isUp() async -> Bool {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/status"))
        request.timeoutInterval = 1.5
        guard let (_, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse else { return false }
        return http.statusCode == 200
    }

    /// Wait until the server answers (used before showing the window).
    nonisolated static func waitUntilUp(seconds: Double = 25) async -> Bool {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if await isUp() { return true }
            try? await Task.sleep(for: .milliseconds(500))
        }
        return false
    }
}
