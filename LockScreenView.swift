//
//  LockScreenView.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-05.
//

import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject var lockManager: LockManager
    @State private var passwordInput = ""
    @State private var hasError = false
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("App is Locked")
                .font(.title2)
                .fontWeight(.bold)
            
            SecureField("Enter Password", text: $passwordInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 200)
            
            if hasError {
                Text("Incorrect Password")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Unlock") {
                if !lockManager.unlock(password: passwordInput) {
                    hasError = true
                    passwordInput = ""
                }
            }
            .keyboardShortcut(.defaultAction)
            
            Spacer()
            
            // <<<<<<< دکمه جدید برای فراموشی رمز عبور
            Button("Forgot Password?") {
                showingResetAlert = true
            }
            .buttonStyle(LinkButtonStyle())
            .foregroundColor(.secondary)
            .padding(.bottom)
            
        }
        .frame(width: 350, height: 400)
        // <<<<<<< نمایش هشدار قبل از درخواست تأیید هویت
        .alert("Are you sure?", isPresented: $showingResetAlert) {
            Button("Reset App", role: .destructive) {
                // اگر کاربر تأیید کرد، حالا تابع امن را فراخوانی کن
                lockManager.requestResetWithAuthentication()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("If you forgot your password, the only way to continue is to reset the app. This will remove your password and permanently delete your entire clipboard history.")
        }
    }
}
