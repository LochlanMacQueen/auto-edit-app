import AppKit

/// auto-edit runs the editor headless by default: projects open and render for the agent,
/// but no Home or editor window is shown. "Show Video Editor" in the auto-edit menu reveals it.
@MainActor
enum AutoEditMode {
    private static let key = "autoedit.showEditor"

    static var editorVisible: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    static var editorHidden: Bool { !editorVisible }

    /// Reveal the editor for the active project (or Home) — the "advanced" path.
    static func revealEditor() {
        editorVisible = true
        if let project = AppState.shared.activeProject ?? AppState.shared.openProjects.first {
            project.showWindows()
            project.windowControllers.first?.window?.makeKeyAndOrderFront(nil)
        } else {
            HomeWindowController.shared.showWindow(nil)
        }
    }

    static func hideEditor() {
        editorVisible = false
        for project in AppState.shared.openProjects {
            project.windowControllers.forEach { $0.window?.orderOut(nil) }
        }
        HomeWindowController.shared.window?.orderOut(nil)
        AutoEditWindowController.shared.show(section: "start")
    }
}
