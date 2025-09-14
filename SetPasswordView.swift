//
//  SetPasswordView.swift
//  ClipboardManagerPro
//
//  Created by Behzad Farhadi on 2025-09-05.
//

import SwiftUI

struct SetPasswordView: View {
    @EnvironmentObject var lockManager: LockManager
    @Environment(\.dismiss) var dismiss
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(lockManager.isPasswordSet ? "Change Password" : "Set a Password")
                .font(.title2)
            
            SecureField("New Password", text: $newPassword)
            SecureField("Confirm Password", text: $confirmPassword)
            
            if let message = errorMessage {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                Button("Cancel") { dismiss() }
                
                Spacer()
                
                Button("Save") {
                    savePassword()
                }
            }
            
            if lockManager.isPasswordSet {
                Button("Remove Password", role: .destructive) {
                    lockManager.removePassword()
                    dismiss()
                }
                .padding(.top)
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    private func savePassword() {
        if newPassword.isEmpty {
            errorMessage = "Password cannot be empty."
            return
        }
        if newPassword != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }
        
        lockManager.setPassword(newPassword: newPassword)
        dismiss()
    }
}
