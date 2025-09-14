//
//  ClipboardManagerProApp.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-04.
//

import SwiftUI

@main
struct ClipboardManagerProApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // پنجره تنظیمات را دوباره به روش مدرن SwiftUI معرفی می‌کنیم
        Settings {
            SettingsView()
        }
    }
}
