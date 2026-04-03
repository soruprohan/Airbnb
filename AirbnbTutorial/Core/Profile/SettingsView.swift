//  SettingsView.swift
//  AirbnbTutorial

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    //It persists the value to the device's local storage
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("emailUpdatesEnabled") private var emailUpdatesEnabled = false
    @AppStorage("selectedCurrency") private var selectedCurrency = "USD"
    
    let currencies = ["USD", "EUR", "GBP", "BDT", "CAD", "AUD", "JPY"]
    
    var body: some View {
        List {
            
            // MARK: - Account
            if let user = authViewModel.currentUser {
                Section("Account") {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Text(user.fullName.prefix(1).uppercased())
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.fullName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(user.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // MARK: - Notifications
            Section("Notifications") {
                Toggle("Push notifications", isOn: $notificationsEnabled)
                Toggle("Email updates", isOn: $emailUpdatesEnabled)
            }
            
            // MARK: - Region
            Section("Region") {
                Picker("Currency", selection: $selectedCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
            }
            
            // MARK: - Legal
            Section("Legal") {
                NavigationLink {
                    SimpleLegalView(
                        title: "Privacy Policy",
                        content: "Your privacy is important to us. We collect only the data necessary to provide the service, such as your email and name upon registration. We do not sell your data to third parties."
                    )
                } label: {
                    Text("Privacy Policy")
                }
                
                NavigationLink {
                    SimpleLegalView(
                        title: "Terms of Service",
                        content: "By using this app you agree to our terms. This app is a tutorial project and is not affiliated with Airbnb, Inc. All listing data is sourced from third-party APIs for demonstration purposes only."
                    )
                } label: {
                    Text("Terms of Service")
                }
            }
            
            // MARK: - Sign out / log in
            Section {
                if authViewModel.currentUser != nil {
                    Button(role: .destructive) {
                        authViewModel.signOut()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Log out")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                } else {
                    NavigationLink {
                        LoginView()
                            .environmentObject(authViewModel)
                    } label: {
                        Text("Log in")
                            .fontWeight(.semibold)
                            .foregroundStyle(.pink)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Legal page
struct SimpleLegalView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            Text(content)
                .font(.body)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
