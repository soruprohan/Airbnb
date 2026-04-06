//
//  RegistrationView.swift
//  AirbnbTutorial
//
//  Created by sorup rohan on 5/3/26.
//

//  RegistrationView.swift

import SwiftUI

struct RegistrationView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            VStack(spacing: 8) {
                Image(systemName: "house.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.pink)
                
                Text("Create an account")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Sign up to start exploring")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)
            
            // Fields
            VStack(spacing: 12) {
                TextField("Full name", text: $fullName)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Error message
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Register button
            Button {
                Task { await handleRegister() }
            } label: {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text("Sign up")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .disabled(isLoading)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private func handleRegister() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authViewModel.register(email: email, password: password, fullName: fullName)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel())
}
