//
//  Listing.swift
//  AirbnbTutorial

import Foundation

struct Listing: Identifiable, Codable, Hashable {
    let id: String
    let ownerUid: String
    let ownerName: String
    let ownerImageUrl: String
    let numberOfBedrooms: Int
    let numberOfBathrooms: Int
    let numberOfGuests: Int
    let numberOfBeds : Int
    var pricePerNight: Int
    let latitude: Double
    let longitude: Double
    var imageURLs: [String]
    let address: String
    let city: String
    let state: String
    let title: String
    var rating: Double
    var features: [ListingFeatures]
    let type: ListingType
}

enum ListingFeatures : Int, Codable, Identifiable, Hashable {
    case selfCheckIn
    case superHost
    
    var imageName: String {
        switch self {
        case .selfCheckIn: return "door.left.hand.open"
        case .superHost: return "medal"
        }
    }

    var title: String {
        switch self {
        case .selfCheckIn: return "Self check-in"
        case .superHost: return "Superhost"
        }
    }

    var subtitle: String {
        switch self {
        case .selfCheckIn:
            return "Check yourself in with the keypad."
        case .superHost:
            return "Superhosts are experienced, highly rated hosts who are commited to providing greate stars for guests."
        }
    }
    
    var id: Int { return self.rawValue } //returns 0 for selfCheckIn, 1 for superHost
}

enum ListingType: Int, Codable, Identifiable, Hashable {
    case apartment
    case house
    case townHouse
    case villa

    var description: String {
        switch self {
        case .apartment: return "Apartment"
        case .house: return "House"
        case .townHouse: return "Town Home"
        case .villa: return "Villa"
        }
    }

    var id: Int { return self.rawValue }
}

// MARK: - Preview Data

#if DEBUG
extension Listing {
    static var example: Listing {
        .init(
            id: NSUUID().uuidString,
            ownerUid: NSUUID().uuidString,
            ownerName: "John Smith",
            ownerImageUrl: "male-profile-photo",
            numberOfBedrooms: 4,
            numberOfBathrooms: 3,
            numberOfGuests: 4,
            numberOfBeds: 4,
            pricePerNight: 68040, // 567 USD × 120 = BDT
            latitude: 25.7850,
            longitude: -80.1936,
            imageURLs: ["listing-2", "listing-1", "listing-3", "listing-4"],
            address: "124 Main St",
            city: "Miami",
            state: "Florida",
            title: "Miami Villa",
            rating: 4.86,
            features: [.selfCheckIn, .superHost],
            type: .villa
        )
    }
}
#endif
