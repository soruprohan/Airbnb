//
//  Wishlist.swift
//  AirbnbTutorial
//
//  Created by sorup rohan on 5/3/26.
//

///
//  Wishlist.swift
//  AirbnbTutorial
//

import Foundation

struct Wishlist: Identifiable, Codable {
    var id: String
    let userId: String
    var name: String
    var listingIds: [String]
    var savedListings: [Listing]

    init(id: String = NSUUID().uuidString,
         userId: String,
         name: String,
         listingIds: [String] = [],
         savedListings: [Listing] = []) {
        self.id = id
        self.userId = userId
        self.name = name
        self.listingIds = listingIds
        self.savedListings = savedListings
    }
}
