//
//  LaunchAtLoginManager.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-04.
//

import Foundation
import ServiceManagement

// <<<<<<< تغییر اصلی: کل کلاس را فقط برای macOS 13 و بالاتر در دسترس قرار می‌دهیم
@available(macOS 13.0, *)
class LaunchAtLoginManager: ObservableObject {
    
    @Published var isEnabled: Bool = false {
        didSet {
            updateLaunchAtLoginStatus()
        }
    }
    
    init() {
        checkCurrentStatus()
    }
    
    private func checkCurrentStatus() {
        let status = SMAppService.mainApp.status
        isEnabled = (status == .enabled)
    }
    
    private func updateLaunchAtLoginStatus() {
        Task { @MainActor in
            do {
                if isEnabled {
                    if SMAppService.mainApp.status == .notRegistered {
                        try SMAppService.mainApp.register()
                    }
                } else {
                    if SMAppService.mainApp.status == .enabled {
                        try SMAppService.mainApp.unregister()
                    }
                }
            } catch {
                print("Failed to update Launch at Login status: \(error)")
                checkCurrentStatus()
            }
        }
    }
}

// این کلاس Legacy دیگر مورد نیاز نیست، چون ما قابلیت را در UI غیرفعال می‌کنیم.
// می‌توانید آن را حذف کنید یا برای سادگی نگه دارید.
