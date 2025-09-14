//
//  LockManager.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-05.
//

import Foundation
import Combine
import LocalAuthentication

class LockManager: ObservableObject {
    @Published var isLocked = false
    @Published var isPasswordSet = false
    @Published var resetError: String?
    
    private let passwordService = PasswordService()
    
    init() {
        if passwordService.read() != nil {
            isPasswordSet = true
            isLocked = true
        }
    }
    
    func unlock(password: String) -> Bool {
        guard let savedPassword = passwordService.read() else { return false }
        
        if password == savedPassword {
            isLocked = false
            return true
        }
        return false
    }
    
    func lock() {
        if isPasswordSet {
            isLocked = true
        }
    }
    
    func setPassword(newPassword: String) {
        do {
            try passwordService.save(password: newPassword)
            isPasswordSet = true
            isLocked = false
        } catch {
            print("Failed to save password: \(error)")
        }
    }
    
    func removePassword() {
        do {
            try passwordService.delete()
            isPasswordSet = false
            isLocked = false
        } catch {
            print("Failed to delete password: \(error)")
        }
    }
    
    func requestResetWithAuthentication() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            // <<<<<<< تغییر اصلی: ترجمه متن به انگلیسی >>>>>>>
            let reason = "Authentication is required to reset your password."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.performSafeReset()
                    } else {
                        self.resetError = "Authentication failed."
                    }
                }
            }
        } else {
            self.resetError = "Biometric authentication is not available on this device."
        }
    }
    
    private func performSafeReset() {
        do {
            try passwordService.delete()
        } catch {
            print("Failed to delete password during reset: \(error)")
        }
        
        // این کد دیگر برای Core Data نیاز نیست، اما برای اطمینان نگه می‌داریم
        UserDefaults.standard.removeObject(forKey: "clipboardHistory_v7")
        
        // حذف دیتابیس Core Data
        let persistenceController = PersistenceController.shared
        persistenceController.deleteAllData()

        self.isPasswordSet = false
        self.isLocked = false
        
        // دیگر نیازی به NotificationCenter نیست چون @FetchRequest خودکار به‌روز می‌شود
    }
}

// این Notification دیگر نیاز نیست چون مستقیم دیتابیس را پاک می‌کنیم
// extension Notification.Name {
//     static let appDidReset = Notification.Name("appDidReset")
// }
