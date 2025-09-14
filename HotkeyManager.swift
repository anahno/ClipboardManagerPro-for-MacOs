//
//  HotkeyManager.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-04.
//

import Foundation
import Carbon // فریم‌ورک مورد نیاز برای کلید میانبر

// این کلاس تمام منطق مربوط به ثبت و مدیریت کلید میانبر را کنترل می‌کند
class HotkeyManager {
    
    // یک ارجاع به AppDelegate برای فراخوانی تابع togglePopover
    private weak var appDelegate: AppDelegate?
    
    // ارجاع به کلید میانبر ثبت شده در سیستم
    private var hotKeyRef: EventHotKeyRef?

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }

    func register() {
        // 1. تعریف ID برای کلید میانبر
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = FourCharCode(string: "mhk1") // یک امضای منحصر به فرد
        hotKeyID.id = 1

        // 2. تعریف خود کلید میانبر (Cmd + Shift + V)
        // Key Code برای 'V' عدد 9 است
        // می‌توانید کدهای کلیدهای دیگر را آنلاین پیدا کنید
        let keyCode = UInt32(kVK_ANSI_V)
        // cmdKey و shiftKey ماسک‌های مربوط به کلیدهای Command و Shift هستند
        let modifiers = UInt32(cmdKey | shiftKey)
        
        // 3. ثبت کلید میانبر در سیستم
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        // این بخش مهم‌ترین قسمت است:
        // ما یک تابع C-Style به نام HotKeyHandler را به سیستم معرفی می‌کنیم
        // که هر وقت کلید میانبر فشرده شد، فراخوانی شود.
        InstallEventHandler(GetApplicationEventTarget(), {
            (nextHandler, event, userData) -> OSStatus in
            
            // از userData برای دسترسی به نمونه HotkeyManager استفاده می‌کنیم
            if let userData = userData {
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.handleHotkey()
            }
            
            return noErr
            
        }, 1, &eventType, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), nil)

        // ثبت نهایی کلید میانبر با سیستم‌عامل
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        // چک می‌کنیم که ثبت موفقیت‌آمیز بوده باشد
        if status != noErr {
            print("Error registering hotkey!")
        }
    }
    
    // این تابع زمانی که کلید میانبر فشرده می‌شود، اجرا خواهد شد
    private func handleHotkey() {
        // به AppDelegate می‌گوییم که Popover را باز/بسته کند
        appDelegate?.togglePopover(nil)
    }
    
    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }
}

// یک ابزار کمکی برای تبدیل رشته به FourCharCode
// این بخش را بدون تغییر کپی کنید
extension FourCharCode {
    init(string: String) {
        self = string.utf16.reduce(0, {$0 << 8 + FourCharCode($1)})
    }
}
