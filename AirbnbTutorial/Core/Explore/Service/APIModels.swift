//
//  APIModels.swift
//  AirbnbTutorial
//

import Foundation

// MARK: - Top-level response (airbnb13)

struct APISearchResponse: Codable {
    let error: Bool // indicates if the API call failed
    let results: [APISearchResult]? //array of individual listings (optional, may be null if there's an error)
}

// MARK: - Each result item

struct APISearchResult: Codable {
    let id: String
    let name: String?
    let city: String?
    let address: String? //not used
    let images: [String]?
    let lat: Double?
    let lng: Double?
    let rating: Double?
    let isSuperhost: Bool?
    let hostThumbnail: String?
    let bathrooms: Double?
    let bedrooms: Int?
    let beds: Int?
    let persons: Int?
    let type: String?
    let price: APIPrice?
    //let host: String?  //to get the host name
}

// MARK: - Price

struct APIPrice: Codable {
    let rate: Int?
    let currency: String? //not used, but could be useful for future
}

// MARK: - Mapping: APISearchResult → Listing

extension APISearchResult {
    func toListing(searchedCity: String, searchedState: String) -> Listing? {
        let listingId = id
        let title = name ?? "Airbnb Listing"
        let city = city ?? searchedCity
        let lat = lat ?? 0
        let lng = lng ?? 0
        let imageURLs = images ?? []
        let pricePerNight = price?.rate ?? 0
        let ratingDouble = rating ?? 0
        let ownerImageUrl = hostThumbnail ?? ""
        let isSuperhost = isSuperhost ?? false

        // Map type string → ListingType enum
        let listingType: ListingType
        switch (type ?? "").lowercased() {
        case let t where t.contains("house"):    listingType = .house
        case let t where t.contains("villa"):    listingType = .villa
        case let t where t.contains("town"):     listingType = .townHouse
        default:                                 listingType = .apartment
        }

        return Listing(
            id: listingId,
            ownerUid: "external",
            ownerName: "Host",  //hardcoded //to get the real ---> ownerName: host ?? "Host"
            ownerImageUrl: ownerImageUrl,
            numberOfBedrooms: bedrooms ?? 1,
            numberOfBathrooms: Int(bathrooms ?? 1),
            numberOfGuests: persons ?? 2,
            numberOfBeds: beds ?? 1,
            pricePerNight: pricePerNight,
            latitude: lat,
            longitude: lng,
            imageURLs: imageURLs,
            address: address ?? city,
            city: city,
            state: searchedState,
            title: title,
            rating: ratingDouble,
            features: isSuperhost ? [.superHost, .selfCheckIn] : [.selfCheckIn],
            amenities: [.wifi, .kitchen], //hardcoded for now since API doesn't provide amenities data
            type: listingType
        )
    }
}
