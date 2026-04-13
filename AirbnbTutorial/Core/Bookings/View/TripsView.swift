//  TripsView.swift
//  AirbnbTutorial

import SwiftUI

struct TripsView: View {
    @EnvironmentObject var bookingViewModel: BookingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLoginSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.userSession == nil {
                    emptyState(
                        icon: "suitcase",
                        title: "Log in to see your trips",
                        subtitle: "Once you book a trip, it will appear here.",
                        showLogin: true
                    )
                } else if bookingViewModel.isLoading {
                    ProgressView()
                } else if bookingViewModel.bookings.isEmpty {
                    emptyState(
                        icon: "airplane",
                        title: "No trips yet",
                        subtitle: "When you book a trip, it will show up here.",
                        showLogin: false
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(bookingViewModel.bookings) { booking in
                                NavigationLink(destination: BookingDetailView(booking: booking)
                                    .environmentObject(bookingViewModel)
                                ) {
                                    BookingRowView(booking: booking)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Trips")
            .task {
                await bookingViewModel.fetchBookings()
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }

    // MARK: - Empty state
    @ViewBuilder
    private func emptyState(icon: String, title: String, subtitle: String, showLogin: Bool) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 90, height: 90)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if showLogin {
                Button {
                    showLoginSheet = true
                } label: {
                    Text("Log in")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 200, height: 50)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Booking card
struct BookingRowView: View {
    let booking: Booking

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Image
            if let url = URL(string: booking.listingImageURL) {
                AsyncImage(url: url) { phase in
                    if let img = phase.image {
                        img.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(Color(.systemGray5))
                            .overlay {
                                ProgressView()
                            }
                    }
                }
                .frame(height: 200)
                .clipped()
            }

            // Info
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(booking.listingTitle)
                            .font(.headline)
                            .lineLimit(1)
                        Text(booking.city)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    StatusBadge(status: booking.status)
                }

                Divider()

                HStack {
                    Label(booking.formattedDateRange, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("$\(booking.totalPrice)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .padding(14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Status badge
struct StatusBadge: View {
    let status: BookingStatus

    var body: some View {
        Text(status == .confirmed ? "Confirmed" : "Cancelled")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status == .confirmed ? Color.green.opacity(0.12) : Color.red.opacity(0.1))
            .foregroundStyle(status == .confirmed ? .green : .red)
            .clipShape(Capsule())
    }
}

// MARK: - Full booking detail screen
struct BookingDetailView: View {
    @EnvironmentObject var bookingViewModel: BookingViewModel
    let booking: Booking
    @State private var showCancelAlert = false
    @Environment(\.dismiss) var dismiss

    private var nights: Int {
        max(1, Calendar.current.dateComponents([.day], from: booking.checkIn, to: booking.checkOut).day ?? 1)
    }

    private var formattedCheckIn: String {
        let f = DateFormatter(); f.dateFormat = "EEE, MMM d, yyyy"
        return f.string(from: booking.checkIn)
    }

    private var formattedCheckOut: String {
        let f = DateFormatter(); f.dateFormat = "EEE, MMM d, yyyy"
        return f.string(from: booking.checkOut)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Hero image
                if let url = URL(string: booking.listingImageURL) {
                    AsyncImage(url: url) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                        } else {
                            Rectangle().fill(Color(.systemGray5))
                        }
                    }
                    .frame(height: 280)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 24) {

                    // Title + status
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(booking.listingTitle)
                                .font(.title2).fontWeight(.bold)
                            Text(booking.city)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        StatusBadge(status: booking.status)
                    }

                    Divider()

                    // Dates card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your stay").font(.headline)

                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Check-in")
                                    .font(.caption).foregroundStyle(.secondary)
                                Text(formattedCheckIn)
                                    .font(.subheadline).fontWeight(.semibold)
                            }
                            Spacer()
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 1, height: 36)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Check-out")
                                    .font(.caption).foregroundStyle(.secondary)
                                Text(formattedCheckOut)
                                    .font(.subheadline).fontWeight(.semibold)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack {
                            Label("\(nights) night\(nights > 1 ? "s" : "")", systemImage: "moon.fill")
                                .foregroundStyle(.blue)
                            Spacer()
                            Label("\(booking.numberOfGuests) guest\(booking.numberOfGuests > 1 ? "s" : "")", systemImage: "person.2.fill")
                                .foregroundStyle(.blue)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 4)
                    }

                    Divider()

                    // Price breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Price details").font(.headline)

                        let perNight = booking.numberOfNights > 0 ? booking.totalPrice / booking.numberOfNights : booking.totalPrice

                        HStack {
                            Text("$\(perNight) × \(nights) night\(nights > 1 ? "s" : "")")
                            Spacer()
                            Text("$\(booking.totalPrice)")
                        }
                        .font(.subheadline)

                        HStack {
                            Text("Service fee")
                            Spacer()
                            Text("$0")
                        }
                        .font(.subheadline).foregroundStyle(.secondary)

                        Divider()

                        HStack {
                            Text("Total (before taxes)").fontWeight(.semibold)
                            Spacer()
                            Text("$\(booking.totalPrice)").fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }

                    Divider()

                    // Booked on
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Booked on").font(.caption).foregroundStyle(.secondary)
                        let f = DateFormatter()
                        let _ = { f.dateFormat = "MMM d, yyyy" }()
                        Text(f.string(from: booking.createdAt))
                            .font(.subheadline)
                    }

                    // Cancel button
                    if booking.status == .confirmed {
                        Button(role: .destructive) {
                            showCancelAlert = true
                        } label: {
                            Text("Cancel reservation")
                                .font(.subheadline).fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .alert("Cancel reservation?", isPresented: $showCancelAlert) {
                            Button("Keep it", role: .cancel) {}
                            Button("Cancel reservation", role: .destructive) {
                                Task {
                                    await bookingViewModel.cancelBooking(booking)
                                    dismiss()
                                }
                            }
                        } message: {
                            Text("This can't be undone. Your booking will be marked as cancelled.")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
