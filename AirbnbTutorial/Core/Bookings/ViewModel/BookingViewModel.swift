//  BookingViewModel.swift
//  AirbnbTutorial

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

@MainActor
class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    // MARK: - Fetch all bookings for current user
    func fetchBookings() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        do {
            let snapshot = try await db
                .collection("users").document(uid)
                .collection("bookings")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            self.bookings = snapshot.documents.compactMap {
                try? $0.data(as: Booking.self)
            }
        } catch {
            self.errorMessage = "Failed to load trips."
        }
        isLoading = false
    }

    // MARK: - Create a booking
    func createBooking(listing: Listing, checkIn: Date, checkOut: Date, guests: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])
        }
        let nights = Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 1
        let total = listing.pricePerNight * nights

        let booking = Booking(
            userId: uid,
            listingId: listing.id,
            listingTitle: listing.title,
            listingImageURL: listing.imageURLs.first ?? "",
            city: listing.city,
            checkIn: checkIn,
            checkOut: checkOut,
            totalPrice: total,
            numberOfGuests: guests,
            status: .confirmed,
            createdAt: Date()
        )

        let encoded = try Firestore.Encoder().encode(booking)
        try await db
            .collection("users").document(uid)
            .collection("bookings")
            .addDocument(data: encoded)

        await fetchBookings()
    }

    // MARK: - Cancel a booking (keeps the record, just updates status)
    func cancelBooking(_ booking: Booking) async {
        guard let uid = Auth.auth().currentUser?.uid,
              let bookingId = booking.id else { return }
        do {
            try await db
                .collection("users").document(uid)
                .collection("bookings").document(bookingId)
                .updateData(["status": BookingStatus.cancelled.rawValue])
            await fetchBookings()
        } catch {
            self.errorMessage = "Failed to cancel booking."
        }
    }

    // MARK: - Availability check (prevents double booking)
    func isListingAvailable(listingId: String, checkIn: Date, checkOut: Date) async -> Bool {
        // Query ALL users' bookings for this listing to check overlap
        // We store a top-level collection for availability checks
        do {
            let snapshot = try await db
                .collectionGroup("bookings")
                .whereField("listingId", isEqualTo: listingId)
                .whereField("status", isEqualTo: BookingStatus.confirmed.rawValue)
                .getDocuments()

            let existing = snapshot.documents.compactMap {
                try? $0.data(as: Booking.self)
            }

            // Check if any existing booking overlaps the requested range
            for b in existing {
                // Overlap condition: requested start < existing end AND requested end > existing start
                if checkIn < b.checkOut && checkOut > b.checkIn {
                    return false // overlaps — not available
                }
            }
            return true
        } catch {
            // If the query fails (e.g. missing index), allow booking to proceed
            print("DEBUG: availability check failed — \(error)")
            return true
        }
    }

    // Convenience: count of confirmed bookings
    var confirmedCount: Int {
        bookings.filter { $0.status == .confirmed }.count
    }
}
