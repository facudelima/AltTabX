import Cocoa

class AboutTab {
    static func initTab() -> NSView {
        makeContentView()
    }

    static func makeContentView(_ fitToContent: Bool = true, _ showFeedbackButton: Bool = true, _ centerHero: Bool = false) -> NSView {
        let appIcon = LightImageView()
        appIcon.translatesAutoresizingMaskIntoConstraints = false
        let appIconSize = NSSize(width: 128, height: 128)
        appIcon.updateContents(.cgImage(App.appIcon(for: appIconSize)), appIconSize)
        appIcon.fit(128, 128)
        var infoRows: [NSView] = [
            BoldLabel(App.name),
            NSTextField(wrappingLabelWithString: NSLocalizedString("Version", comment: "") + " " + App.version),
            NSTextField(wrappingLabelWithString: App.licence),
        ]
        if let website = AltTabXBranding.website {
            infoRows.append(HyperlinkLabel(NSLocalizedString("Website", comment: ""), website))
        }
        if !App.repository.isEmpty {
            infoRows.append(HyperlinkLabel(NSLocalizedString("Source code", comment: ""), App.repository))
        }
        let appText = StackView(infoRows, .vertical)
        appText.spacing = GridView.interPadding / 2
        let appInfo = NSStackView(views: [appIcon, appText])
        appIcon.translatesAutoresizingMaskIntoConstraints = false
        appInfo.spacing = GridView.interPadding
        appInfo.alignment = .centerY
        var rows: [[NSView]] = [[appInfo]]
        if AltTabXBranding.supportProjectEnabled {
            rows.append([makeSupportProjectButton()])
        }
        let grid = GridView(rows, 0)
        if centerHero {
            grid.cell(atColumnIndex: 0, rowIndex: 0).xPlacement = .center
        }
        if AltTabXBranding.supportProjectEnabled, rows.count > 1 {
            grid.cell(atColumnIndex: 0, rowIndex: 1).xPlacement = .center
        }
        if fitToContent {
            grid.fit()
        }
        return grid
    }

    static func makeSupportProjectButton() -> NSButton {
        let button = makeButtonWithIcon(NSLocalizedString("Support this project", comment: ""), App.supportProjectAction, "heart.fill", .red, App.self)
        styleSupportProjectButton(button)
        return button
    }

    private static func styleSupportProjectButton(_ button: NSButton) {
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    private static func makeButtonWithIcon(_ title: String, _ selector: Selector, _ symbolName: String?, _ color: NSColor? = nil, _ target: AnyObject? = nil) -> NSButton {
        let button = NSButton(title: title, target: target, action: selector)
        if #available(macOS 26.0, *), let symbolName {
            button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
            button.imagePosition = .imageLeading
            if let color {
                button.image = button.image?.withSymbolConfiguration(.init(paletteColors: [color]))
            }
        }
        return button
    }
}

class AboutWindow: NSPanel {
    private static let contentPadding = CGFloat(24)
    static var shared: AboutWindow?

    static var canBecomeKey_ = true
    override var canBecomeKey: Bool { Self.canBecomeKey_ }

    convenience init() {
        self.init(contentRect: NSRect(x: 0, y: 0, width: 380, height: 220), styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        setupWindow()
        setupView()
        setFrameAutosaveNameSafely("AboutWindow2")
        Self.shared = self
    }

    private func setupWindow() {
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        title = String(format: NSLocalizedString("About %@", comment: ""), App.name)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
    }

    private func setupView() {
        let aboutView = AboutTab.makeContentView(false, false, true)
        aboutView.translatesAutoresizingMaskIntoConstraints = false
        let container = FlippedView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(aboutView)
        contentView = container
        NSLayoutConstraint.activate([
            aboutView.topAnchor.constraint(equalTo: container.topAnchor, constant: Self.contentPadding),
            aboutView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Self.contentPadding),
            aboutView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Self.contentPadding),
            aboutView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Self.contentPadding),
        ])
    }

    override func close() {
        hideAppIfLastWindowIsClosed()
        super.close()
    }
}
