import Cocoa

class PermissionsWindow: NSWindow {
    static var accessibilityView: PermissionView!
    static var screenRecordingView: PermissionView!
    static var canBecomeKey_ = true
    override var canBecomeKey: Bool { Self.canBecomeKey_ }
    static var shared: PermissionsWindow!

    convenience init() {
        self.init(contentRect: .zero, styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        delegate = self
        setupWindow()
        setupView()
        setFrameAutosaveNameSafely("PermissionsWindow")
        Self.shared = self
    }

    static func updatePermissionViews() {
        accessibilityView.updatePermissionStatus(AccessibilityPermission.status)
        if #available(macOS 10.15, *) {
            screenRecordingView.updatePermissionStatus(ScreenRecordingPermission.status)
        }
    }

    static func show() {
        guard !Self.shared.isVisible else { return }
        Logger.debug { "" }
        Self.shared.center()
        App.shared.activate(ignoringOtherApps: true)
        Self.shared.makeKeyAndOrderFront(nil)
        SystemPermissions.setFrequentTimer()
    }

    private func setupWindow() {
        title = String(format: NSLocalizedString("%@ needs some permissions", comment: ""), App.name)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        styleMask.insert([.closable])
    }

    private func setupView() {
        let appIcon = LightImageView()
        appIcon.translatesAutoresizingMaskIntoConstraints = false
        let appIconSize = NSSize(width: 80, height: 80)
        appIcon.updateContents(.cgImage(App.appIcon(for: appIconSize)), appIconSize)
        appIcon.fit(80, 80)
        let appText = TitleLabel(String(format: NSLocalizedString("%@ needs some permissions", comment: ""), App.name))
        appText.preferredMaxLayoutWidth = 380
        appText.font = .systemFont(ofSize: 25, weight: .regular)
        let pathHint = NSTextField(wrappingLabelWithString: "")
        pathHint.translatesAutoresizingMaskIntoConstraints = false
        pathHint.preferredMaxLayoutWidth = 500
        pathHint.font = .systemFont(ofSize: 11)
        pathHint.textColor = .secondaryLabelColor
        pathHint.stringValue = NSLocalizedString(
            "In System Settings, enable this exact app (not “AltTab” from another install). After toggling the permission, restart the app:",
            comment: "Permissions window path hint"
        ) + "\n" + Bundle.main.bundlePath
        let restartButton = Button(NSLocalizedString("Restart AltTabNeo", comment: "After granting accessibility")) { _ in App.restart() }
        let restartRow = NSStackView(views: [restartButton])
        restartRow.translatesAutoresizingMaskIntoConstraints = false
        restartRow.alignment = .leading
        let header = NSStackView(views: [appIcon, appText])
        header.translatesAutoresizingMaskIntoConstraints = false
        header.spacing = GridView.interPadding
        let headerColumn = NSStackView(views: [header, pathHint])
        headerColumn.translatesAutoresizingMaskIntoConstraints = false
        headerColumn.orientation = .vertical
        headerColumn.spacing = 8
        headerColumn.alignment = .leading
        Self.accessibilityView = PermissionView(
            .accessibility,
            NSLocalizedString("Accessibility", comment: ""),
            NSLocalizedString("This permission is needed to focus windows after you release the shortcut", comment: ""),
            NSLocalizedString("Open Accessibility Settings…", comment: ""),
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
        )
        var rows = [
            [headerColumn],
            [Self.accessibilityView],
        ]
        if #available(macOS 10.15, *) {
            Self.screenRecordingView = PermissionView(
                .display,
                NSLocalizedString("Screen Recording", comment: ""),
                NSLocalizedString("This permission is needed to show thumbnails and preview of open windows", comment: ""),
                NSLocalizedString("Open Screen Recording Settings…", comment: ""),
                "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture",
                StackView(LabelAndControl.makeLabelWithCheckbox(NSLocalizedString("Use the app without this permission. Thumbnails won’t show.", comment: ""), "screenRecordingPermissionSkipped", labelPosition: .right))
            )
            rows.append([Self.screenRecordingView])
        }
        rows.append([restartRow])
        let widestRowWidth = rows.reduce(0) { max($0, $1[0]!.fittingSize.width) }
        rows.forEach { $0[0]!.fit(widestRowWidth, $0[0]!.fittingSize.height) }
        let view = GridView(rows as! [[NSView]])
        view.fit()
        contentView = view.wrappedWithTitlebarPadding()
        setContentSize(contentView!.fittingSize)
    }

    override func close() {
        hideAppIfLastWindowIsClosed()
        super.close()
    }
}

extension PermissionsWindow: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        Logger.debug { "preStartupPermissionsPassed:\(SystemPermissions.preStartupPermissionsPassed), accessibility:\(AccessibilityPermission.status), screenRecording:\(ScreenRecordingPermission.status)" }
        if !SystemPermissions.preStartupPermissionsPassed {
            if AccessibilityPermission.status == .notGranted {
                Logger.error {
                    """
                    Before using this app, grant Accessibility for \(Bundle.main.bundlePath) in
                    System Settings > Privacy & Security > Accessibility, then relaunch.
                    """
                }
                App.shared.terminate(self)
                return false
            }
        }
        return true
    }
}
