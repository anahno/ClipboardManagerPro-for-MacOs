//
//  AppDelegate.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-04.
//
import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, DirectoryMonitorDelegate {
    
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var clipboardManager: ClipboardManager!
    var lockManager: LockManager!
    
    // <<<<<<< ۱. اضافه کردن کنترلر دیتابیس
    let persistenceController = PersistenceController.shared
    
    // تمام سرویس‌های برنامه
    private var hotkeyManager: HotkeyManager?
    private var desktopMonitor: DirectoryMonitor?
    private var lastProcessedFileURL: URL?
    
    // پنجره‌ها
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // کد پاک‌سازی یک‌باره برای حذف داده‌های قدیمی و فاسد
        let cleanInstallKey = "hasPerformedCleanInstall_CoreData_v1"
        if !UserDefaults.standard.bool(forKey: cleanInstallKey) {
            UserDefaults.standard.removeObject(forKey: "clipboardHistory_v5")
            UserDefaults.standard.removeObject(forKey: "clipboardHistory_v6")
            UserDefaults.standard.removeObject(forKey: "clipboardHistory_v7")

            if let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let imageDir = appSupportURL.appendingPathComponent("behzadfarhadi.ClipboardManagerPro/ImageHistory")
                try? FileManager.default.removeItem(at: imageDir)
            }
            
            UserDefaults.standard.set(true, forKey: cleanInstallKey)
            print("PERFORMED A ONE-TIME CLEAN INSTALLATION OF LEGACY APP DATA.")
        }
        
        // --- راه‌اندازی تمام بخش‌های برنامه ---
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager")
            button.action = #selector(togglePopover(_:))
        }

        // <<<<<<< ۲. پاس دادن context دیتابیس به ClipboardManager
        clipboardManager = ClipboardManager(context: persistenceController.container.viewContext)
        lockManager = LockManager()

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 350, height: 400)
        popover?.behavior = .transient
        
        // <<<<<<< ۳. تزریق context دیتابیس به کل محیط SwiftUI
        popover?.contentViewController = NSHostingController(
            rootView: ContentView(clipboardManager: clipboardManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(lockManager)
        )
        
        clipboardManager.startListening()
        hotkeyManager = HotkeyManager(appDelegate: self)
        hotkeyManager?.register()
        
        if let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first {
            desktopMonitor = DirectoryMonitor(url: desktopURL)
            desktopMonitor?.delegate = self
            desktopMonitor?.startMonitoring()
        }
        
        setupMenus()
    }
    
    func applicationDidBecomeActive(_ aNotification: Notification) { }
    
    private func setupMenus() {
        let mainMenu = NSMenu()
        let appMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        let aboutItem = NSMenuItem(title: "About ClipboardManager Pro", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        appMenu.addItem(aboutItem)
        appMenu.addItem(NSMenuItem.separator())
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettingsWindow), keyEquivalent: ",")
        settingsItem.target = self
        appMenu.addItem(settingsItem)
        appMenu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit ClipboardManager Pro", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.addItem(quitItem)
        mainMenu.addItem(appMenuItem)
        let editMenu = NSMenu(title: "Edit")
        let editMenuItem = NSMenuItem()
        editMenuItem.submenu = editMenu
        let copyItem = NSMenuItem(title: "Copy", action: #selector(copy(_:)), keyEquivalent: "c")
        let pasteItem = NSMenuItem(title: "Paste", action: #selector(paste(_:)), keyEquivalent: "v")
        editMenu.addItem(copyItem)
        editMenu.addItem(pasteItem)
        mainMenu.addItem(editMenuItem)
        let windowMenu = NSMenu(title: "Window")
        let windowMenuItem = NSMenuItem()
        windowMenuItem.submenu = windowMenu
        let minimizeItem = NSMenuItem(title: "Minimize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(minimizeItem)
        mainMenu.addItem(windowMenuItem)
        NSApp.mainMenu = mainMenu
        NSApp.servicesMenu = NSMenu()
    }
    
    @objc func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }
    
    @objc func showSettingsWindow() {
        if settingsWindow == nil {
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 450),
                styleMask: [.titled, .closable], backing: .buffered, defer: false)
            settingsWindow?.title = "Settings"
            settingsWindow?.contentView = NSHostingView(rootView: SettingsView())
            settingsWindow?.center()
            settingsWindow?.setFrameAutosaveName("SettingsWindow")
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func copy(_ sender: Any?) { NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: sender) }
    @objc func paste(_ sender: Any?) { NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: sender) }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(sender)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.becomeKey()
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        hotkeyManager?.unregister()
        desktopMonitor?.stopMonitoring()
    }
    
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkForNewScreenshots()
        }
    }
    
    private func checkForNewScreenshots() {
        guard let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: desktopURL, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            
            let latestPNG = fileURLs
                .filter { $0.pathExtension.lowercased() == "png" }
                .max(by: { (url1, url2) -> Bool in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? .distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? .distantPast
                    return date1 < date2
                })
            
            guard let latestScreenshotURL = latestPNG,
                  latestScreenshotURL != lastProcessedFileURL else {
                return
            }

            if let creationDate = (try? latestScreenshotURL.resourceValues(forKeys: [.creationDateKey]))?.creationDate,
               Date().timeIntervalSince(creationDate) < 5 {
                
                if let image = NSImage(contentsOf: latestScreenshotURL) {
                    self.clipboardManager.addImageFromFile(image: image, url: latestScreenshotURL)
                    self.lastProcessedFileURL = latestScreenshotURL
                }
            }
        } catch {
            print("Error checking for screenshots: \(error)")
        }
    }
}
