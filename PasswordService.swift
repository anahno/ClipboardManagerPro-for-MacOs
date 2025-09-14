//
//  PasswordService.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-05.
//

import Foundation
import Security

// این کلاس برای ذخیره امن رمز در Keychain سیستم است
struct PasswordService {
    private let service = "com.yourcompany.ClipboardManagerPro" // یک شناسه منحصر به فرد برای برنامه شما
    private let account = "app_password"

    // ذخیره رمز عبور
    func save(password: String) throws {
        guard let data = password.data(using: .utf8) else { return }
        
        // ابتدا رمز قبلی را حذف می‌کنیم تا جایگزین شود
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // رمز جدید را اضافه می‌کنیم
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    // خواندن رمز عبور
    func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
            return String(data: retrievedData, encoding: .utf8)
        } else {
            return nil
        }
    }

    // حذف رمز عبور
    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }
}
