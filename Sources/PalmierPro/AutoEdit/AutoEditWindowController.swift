import AppKit
import WebKit

/// The auto-edit panel: Setup, Review (approve / request changes), Queue, Phone, Connect.
/// It is the local dashboard served by the sidecar, shown in a native window.
@MainActor
final class AutoEditWindowController: NSWindowController {
    static let shared = AutoEditWindowController()

    private let webView: WKWebView
    private var loadedOnce = false

    private init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 1120, height: 780), configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        let window = NSWindow(contentRect: webView.frame,
                              styleMask: [.titled, .closable, .miniaturizable, .resizable],
                              backing: .buffered, defer: false)
        window.title = "auto-edit"
        window.minSize = NSSize(width: 760, height: 520)
        window.contentView = webView
        window.center()
        window.setFrameAutosaveName("auto-edit.dashboard")
        window.isReleasedWhenClosed = false
        super.init(window: window)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func show(section: String = "setup") {
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        let url = AutoEditSidecar.baseURL.appendingPathComponent("").absoluteString + "#" + section
        Task { @MainActor in
            if !loadedOnce {
                if await AutoEditSidecar.waitUntilUp() {
                    loadedOnce = true
                    webView.load(URLRequest(url: URL(string: url)!))
                } else {
                    webView.loadHTMLString(Self.offlineHTML, baseURL: nil)
                }
            } else {
                webView.evaluateJavaScript("location.hash='#\(section)'", completionHandler: nil)
            }
        }
    }

    private static let offlineHTML = """
    <html><body style="background:#0b0c10;color:#e8e8ee;font:15px -apple-system;padding:40px">
    <h2>auto-edit server isn't running</h2>
    <p>The bundled server did not start. Check <code>~/AutoEdit/logs/sidecar.log</code>, or run
    <code>python3 -m autoedit serve</code> from the auto-edit repo, then reopen this window.</p></body></html>
    """
}
