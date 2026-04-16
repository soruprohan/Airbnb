//  ProfileView.swift
//  AirbnbTutorial

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookingViewModel: BookingViewModel
    @State private var showLoginSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    if let user = authViewModel.currentUser { // to check whether currentUser has a value
                        loggedInHeader(user: user)
                    } else {
                        loggedOutHeader
                    }

                    // MARK: - Menu options
                    VStack(spacing: 0) {
                        if authViewModel.currentUser != nil {
                            NavigationLink {
                                TripsView()
                                    .environmentObject(bookingViewModel)
                                    .environmentObject(authViewModel)
                            } label: {
                                ProfileOptionRowView(
                                    imageName: "suitcase.fill",
                                    title: "My Trips",
                                    iconColor: .blue
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        NavigationLink {
                            SettingsView()
                                .environmentObject(authViewModel)
                        } label: {
                            ProfileOptionRowView(
                                imageName: "gear",
                                title: "Settings",
                                iconColor: .gray
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            AccessibilityView()
                        } label: {
                            ProfileOptionRowView(
                                imageName: "accessibility",
                                title: "Accessibility",
                                iconColor: .blue
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            HelpCenterView()
                        } label: {
                            ProfileOptionRowView(
                                imageName: "questionmark.circle.fill",
                                title: "Visit the help center",
                                iconColor: .green
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }

    // MARK: - Logged-out header
    private var loggedOutHeader: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Log in to your account")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Start planning your next trip by logging in or creating an account.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                showLoginSheet = true
            } label: {
                Text("Log in")
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 4) {
                Text("Don't have an account?")
                NavigationLink {
                    RegistrationView()
                        .environmentObject(authViewModel)
                } label: {
                    Text("Sign up")
                        .fontWeight(.semibold)
                        .underline()
                        .foregroundStyle(.primary)
                }
            }
            .font(.caption)

            Divider()
        }
        .padding()
    }

    // MARK: - Logged-in header
    private func loggedInHeader(user: AppUser) -> some View { // it's a function (not a computed property) because it takes a user parameter
                                                                //  — the actual logged-in AppUser data to display.
        VStack(spacing: 0) {

            // Hero card
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                        .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)

                    Text(user.fullName.prefix(1).uppercased())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 4) {
                    Text(user.fullName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Stats row
                HStack(spacing: 0) {
                    statCell(
                        value: "\(bookingViewModel.bookings.filter { $0.status == .confirmed }.count)",
                        label: "Trips"
                    )
                    Divider().frame(height: 32)
                    statCell(value: "★ New", label: "Member")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color(.systemBackground))

            Divider()
        }
        .task {
            await bookingViewModel.fetchBookings()
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(BookingViewModel())
}
