//
//  DirectoryMonitor.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-04.
//

import Foundation

// Delegate پروتکلی برای اطلاع رسانی تغییرات
protocol DirectoryMonitorDelegate: AnyObject {
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor)
}

class DirectoryMonitor {
    weak var delegate: DirectoryMonitorDelegate?
    let url: URL // URL پوشه‌ای که قرار است نظارت شود
    
    private var fileDescriptor: CInt = -1 // فایل دسکریپتور برای پوشه
    private var source: DispatchSourceFileSystemObject? // دیسپچ سورس برای گوش دادن به تغییرات

    init(url: URL) {
        self.url = url
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        // مطمئن می‌شویم که قبلاً شروع به نظارت نکرده باشیم
        guard source == nil else { return }

        // 1. باز کردن فایل دسکریپتور برای پوشه
        fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("Failed to open file descriptor for \(url.path)")
            return
        }

        // 2. ایجاد Dispatch Source برای نظارت بر تغییرات
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write, // ما به رویداد 'write' (تغییر محتوا یا اضافه شدن فایل) نیاز داریم
            queue: DispatchQueue.global() // روی یک صف پس‌زمینه اجرا شود
        )

        // 3. تعریف هندلر برای رویدادها
        source?.setEventHandler {
            // وقتی رویدادی رخ داد، به delegate اطلاع بده
            self.delegate?.directoryMonitorDidObserveChange(directoryMonitor: self)
        }

        // 4. تعریف هندلر برای کنسل شدن
        source?.setCancelHandler {
            close(self.fileDescriptor)
            self.fileDescriptor = -1
            self.source = nil
        }

        // 5. شروع به گوش دادن
        source?.resume()
    }

    func stopMonitoring() {
        source?.cancel() // کنسل کردن دیسپچ سورس
    }
}
