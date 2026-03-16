import Cocoa
import SwiftUI

class KeyPanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var panel: KeyPanel!
    var sessionManager = SessionManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "HON"
            button.action = #selector(togglePanel(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        let contentView = ContentView(manager: sessionManager)
        
        panel = KeyPanel(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 350),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.hasShadow = true
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .white
        panel.isOpaque = true
        panel.becomesKeyOnlyIfNeeded = false
        panel.collectionBehavior = [.canJoinAllSpaces, .ignoresCycle]
        
        panel.contentView = NSHostingView(rootView: contentView)
        
        // Setup wellness/idle popup callback
        sessionManager.onPanelAction = { [weak self] in
            DispatchQueue.main.async {
                self?.showPanel()
            }
        }
    }
    
    @objc func togglePanel(_ sender: Any?) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Quit HON", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            if panel.isVisible {
                panel.orderOut(nil)
            } else {
                showPanel()
            }
        }
    }
    
    func showPanel() {
        if let button = statusItem.button, let window = button.window {
            let buttonRect = window.convertToScreen(button.frame)
            let panelWidth: CGFloat = 260
            let xPos = buttonRect.midX - (panelWidth / 2)
            let yPos = buttonRect.minY - panel.frame.height - 5
            
            panel.setFrameOrigin(NSPoint(x: xPos, y: yPos))
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
