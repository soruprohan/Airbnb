//  Booking.swift
//  AirbnbTutorial

import Foundation
import FirebaseFirestoreSwift

enum BookingStatus: String, Codable {
    case confirmed
    case cancelled
}

struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let listingId: String
    let listingTitle: String
    let listingImageURL: String
    let city : String
    let checkIn: Date
    let checkOut: Date
    let totalPrice: Int
    let numberOfGuests: Int
    var status: BookingStatus
    let createdAt: Date

    // Computed — not stored in Firestore
    var numberOfNights: Int {
        Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 1
    }

    var formattedDateRange: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return "\(f.string(from: checkIn)) – \(f.string(from: checkOut))"
    }
}
