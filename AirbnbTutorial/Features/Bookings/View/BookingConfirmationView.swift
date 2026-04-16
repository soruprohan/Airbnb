//  BookingConfirmationView.swift
//  AirbnbTutorial

import SwiftUI

struct BookingConfirmationView: View {
    @EnvironmentObject var exploreViewModel: ExploreViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookingViewModel: BookingViewModel
    @Environment(\.dismiss) var dismiss

    let listing: Listing

    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorText = ""

    // Edit-mode toggles
    @State private var isEditingDates = false
    @State private var isEditingGuests = false

    private var checkIn: Date { exploreViewModel.startDate }
    private var checkOut: Date { exploreViewModel.endDate }
    private var guests: Int { exploreViewModel.numGuests }

    private var nights: Int {
        max(1, Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 1)
    }
    private var totalPrice: Int { listing.pricePerNight * nights }

    private var formattedCheckIn: String {
        let f = DateFormatter(); f.dateFormat = "MMM d, yyyy"
        return f.string(from: checkIn)
    }
    private var formattedCheckOut: String {
        let f = DateFormatter(); f.dateFormat = "MMM d, yyyy"
        return f.string(from: checkOut)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Listing image
                    if let urlStr = listing.imageURLs.first, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Rectangle().fill(Color(.systemGray5))
                            }
                        }
                        .frame(height: 220)
                        .clipped()
                    }

                    VStack(alignment: .leading, spacing: 24) {

                        // Title
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Confirm your booking")
                                .font(.title2).fontWeight(.bold)
                            Text(listing.title)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }

                        Divider()

                        // Dates & guests (editable)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your trip").font(.headline)

                            // ── Dates row ──
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Dates").font(.subheadline).fontWeight(.semibold)
                                    Text("\(formattedCheckIn) → \(formattedCheckOut)")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        isEditingDates.toggle()
                                        if isEditingDates { isEditingGuests = false }
                                    }
                                } label: {
                                    Text(isEditingDates ? "Done" : "Edit")
                                        .font(.subheadline).fontWeight(.semibold)
                                        .foregroundStyle(.blue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                }
                            }

                            // ── Inline date pickers ──
                            if isEditingDates {
                                VStack(spacing: 12) {
                                    DatePicker("Check-in",
                                               selection: $exploreViewModel.startDate,
                                               in: Date()...,
                                               displayedComponents: .date)
                                        .datePickerStyle(.compact)

                                    DatePicker("Check-out",
                                               selection: $exploreViewModel.endDate,
                                               in: exploreViewModel.startDate.addingTimeInterval(86400)...,
                                               displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // ── Guests row ──
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Guests").font(.subheadline).fontWeight(.semibold)
                                    Text("\(guests) guest\(guests > 1 ? "s" : "")")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        isEditingGuests.toggle()
                                        if isEditingGuests { isEditingDates = false }
                                    }
                                } label: {
                                    Text(isEditingGuests ? "Done" : "Edit")
                                        .font(.subheadline).fontWeight(.semibold)
                                        .foregroundStyle(.blue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                }
                            }

                            // ── Inline guest stepper ──
                            if isEditingGuests {
                                HStack {
                                    Text("Number of guests")
                                        .font(.subheadline)

                                    Spacer()

                                    HStack(spacing: 16) {
                                        Button {
                                            if exploreViewModel.numGuests > 1 {
                                                exploreViewModel.numGuests -= 1
                                            }
                                        } label: {
                                            Image(systemName: "minus.circle")
                                                .font(.title2)
                                                .foregroundStyle(exploreViewModel.numGuests > 1 ? .blue : .gray)
                                        }
                                        .disabled(exploreViewModel.numGuests <= 1)

                                        Text("\(exploreViewModel.numGuests)")
                                            .font(.headline)
                                            .frame(minWidth: 28)

                                        Button {
                                            if exploreViewModel.numGuests < listing.numberOfGuests {
                                                exploreViewModel.numGuests += 1
                                            }
                                        } label: {
                                            Image(systemName: "plus.circle")
                                                .font(.title2)
                                                .foregroundStyle(exploreViewModel.numGuests < listing.numberOfGuests ? .blue : .gray)
                                        }
                                        .disabled(exploreViewModel.numGuests >= listing.numberOfGuests)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }

                        Divider()

                        // Price breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Price details").font(.headline)

                            HStack {
                                Text("৳\(listing.pricePerNight) × \(nights) night\(nights > 1 ? "s" : "")")
                                Spacer()
                                Text("৳\(totalPrice)")
                            }
                            .font(.subheadline)

                            HStack {
                                Text("Service fee")
                                Spacer()
                                Text("৳0")
                            }
                            .font(.subheadline).foregroundStyle(.secondary)

                            Divider()

                            HStack {
                                Text("Total (before taxes)").fontWeight(.semibold)
                                Spacer()
                                Text("৳\(totalPrice)").fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }

                        Divider()

                        // Error message
                        if showError {
                            Text(errorText)
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .padding(.vertical, 4)
                        }

                        // Confirm button
                        Button {
                            Task { await confirmBooking() }
                        } label: {
                            HStack {
                                if isProcessing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Confirm Reservation")
                                }
                            }
                            .foregroundStyle(.white)
                            .font(.subheadline).fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isProcessing ? Color.blue.opacity(0.6) : Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(isProcessing)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                }
            }
            // Success overlay
            .overlay {
                if showSuccess {
                    BookingSuccessView {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Confirm booking logic
    private func confirmBooking() async {
        isProcessing = true
        showError = false

        // availability check
        let available = await bookingViewModel.isListingAvailable(
            listingId: listing.id,
            checkIn: checkIn,
            checkOut: checkOut
        )

        guard available else {
            errorText = "These dates are already booked. Please choose different dates."
            showError = true
            isProcessing = false
            return
        }

        do {
            try await bookingViewModel.createBooking(
                listing: listing,
                checkIn: checkIn,
                checkOut: checkOut,
                guests: guests
            )
            withAnimation { showSuccess = true }
        } catch {
            errorText = "Something went wrong. Please try again."
            showError = true
        }
        isProcessing = false
    }
}


// MARK: - Success screen
struct BookingSuccessView: View {
    let onDone: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                Text("You're confirmed!")
                    .font(.title).fontWeight(.bold)
                Text("Your reservation has been saved.\nCheck your Trips tab to manage it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    onDone()
                } label: {
                    Text("Done")
                        .foregroundStyle(.white)
                        .font(.subheadline).fontWeight(.semibold)
                        .frame(width: 200, height: 50)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
        }
    }
}
