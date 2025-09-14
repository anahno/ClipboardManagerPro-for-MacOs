//
//  SettingsView.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-04.
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("historyLimit") private var historyLimit: Int = 20
    
    // <<<<<<< ۱. StateObject را فقط در صورت نیاز ایجاد می‌کنیم
    @StateObject private var launchAtLoginManager: LaunchAtLoginManager
    
    init() {
        // این کار باعث می‌شود برنامه روی نسخه‌های قدیمی‌تر کرش نکند
        if #available(macOS 13.0, *) {
            _launchAtLoginManager = StateObject(wrappedValue: LaunchAtLoginManager())
        } else {
            // یک مقدار خالی برای نسخه‌های قدیمی‌تر
            _launchAtLoginManager = StateObject(wrappedValue: LaunchAtLoginManager.empty())
        }
    }

    var body: some View {
        ZStack {
            VisualEffectView(material: .sidebar, blendingMode: .withinWindow)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                VStack {
                    Image(systemName: "gearshape.fill")
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                    Text("ClipboardManager Pro Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 15) {
                    Text("General")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("History Limit", systemImage: "text.book.closed.fill")
                        Spacer()
                        Stepper("\(historyLimit) items", value: $historyLimit, in: 10...100, step: 5)
                            .frame(width: 120)
                    }
                    
                    // <<<<<<< ۲. شرط اصلی برای نمایش یا عدم نمایش دکمه
                    if #available(macOS 13.0, *) {
                        Toggle(isOn: $launchAtLoginManager.isEnabled) {
                            Label("Launch at Login", systemImage: "arrow.up.right.square.fill")
                        }
                    } else {
                        // متنی که به کاربران نسخه‌های قدیمی‌تر نمایش داده می‌شود
                        HStack {
                            Label("Launch at Login", systemImage: "arrow.up.right.square.fill")
                            Spacer()
                            Text("Requires macOS 13 or newer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Label("Global Hotkey", systemImage: "keyboard.fill")
                        Spacer()
                        Text("⌘ + ⇧ + V")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.gray.opacity(0.2)))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Material.thin)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                )

                Spacer()

                VStack {
                    Text("ClipboardManager Pro").font(.title3).fontWeight(.semibold)
                    Text("Version 1.0.0").font(.caption).foregroundColor(.secondary)
                    Text("Developed with ❤️").font(.caption2).foregroundColor(.gray)
                }
                .padding(.top, 10)
            }
            .padding(25)
        }
        .frame(width: 400, height: 450)
    }
}

// <<<<<<< ۳. یک extension برای ساختن یک نمونه خالی برای نسخه‌های قدیمی
extension LaunchAtLoginManager {
    static func empty() -> LaunchAtLoginManager {
        // این تابع فقط برای جلوگیری از کرش استفاده می‌شود
        // و خود کلاس اصلی همچنان فقط روی macOS 13+ ساخته می‌شود.
        return LaunchAtLoginManager()
    }
}
