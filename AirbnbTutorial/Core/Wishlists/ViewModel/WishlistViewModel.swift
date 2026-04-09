//
//  WishlistViewModel.swift
//  AirbnbTutorial
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class WishlistViewModel: ObservableObject {

    @Published var wishlists: [Wishlist] = []
    @Published var savedListingIds: Set<String> = []

    private let db = Firestore.firestore()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Fetch

    func fetchWishlists() async {
        guard let uid = userId else { return }

        guard let snapshot = try? await db
            .collection("users")
            .document(uid)
            .collection("wishlists")
            .getDocuments() else { return }

        self.wishlists = snapshot.documents.compactMap { //compactMap automatically filters out any documents that fail decoding (instead of crashing)
            try? $0.data(as: Wishlist.self)
        }

        self.savedListingIds = Set(wishlists.flatMap(\.listingIds))
    }

    // MARK: - Create Wishlist

    func createWishlist(name: String, addListing: Listing? = nil) async {
        guard let uid = userId else { return }

        var listingIds: [String] = []
        var savedListings: [Listing] = []

        if let listing = addListing {
            listingIds.append(listing.id)
            savedListings.append(listing)
        }

        let wishlist = Wishlist(
            userId: uid,
            name: name,
            listingIds: listingIds,
            savedListings: savedListings
        )

        guard let encoded = try? Firestore.Encoder().encode(wishlist) else { return }

        try? await db
            .collection("users")
            .document(uid)
            .collection("wishlists")
            .document(wishlist.id)
            .setData(encoded)

        await fetchWishlists()
    }

    // MARK: - Add to a specific wishlist

    func addToSpecificWishlist(listing: Listing, wishlistId: String) async {
        guard let uid = userId else { return }
        guard var wishlist = wishlists.first(where: { $0.id == wishlistId }) else { return }
        guard !wishlist.listingIds.contains(listing.id) else { return }

        wishlist.listingIds.append(listing.id)
        wishlist.savedListings.append(listing)

        guard let encoded = try? Firestore.Encoder().encode(wishlist) else { return }

        try? await db
            .collection("users")
            .document(uid)
            .collection("wishlists")
            .document(wishlistId)
            .setData(encoded)

        await fetchWishlists()
    }

    // MARK: - Remove from a specific wishlist

    func removeFromSpecificWishlist(listingId: String, wishlistId: String) async {
        guard let uid = userId else { return }
        guard var wishlist = wishlists.first(where: { $0.id == wishlistId }) else { return }

        wishlist.listingIds.removeAll { $0 == listingId }
        wishlist.savedListings.removeAll { $0.id == listingId }

        guard let encoded = try? Firestore.Encoder().encode(wishlist) else { return }

        try? await db
            .collection("users")
            .document(uid)
            .collection("wishlists")
            .document(wishlistId)
            .setData(encoded)

        await fetchWishlists()
    }

    // MARK: - Remove from ALL wishlists

    func removeFromAllWishlists(listingId: String) async {
        guard let uid = userId else { return }

        for var wishlist in wishlists where wishlist.listingIds.contains(listingId) {
            wishlist.listingIds.removeAll { $0 == listingId }
            wishlist.savedListings.removeAll { $0.id == listingId }

            guard let encoded = try? Firestore.Encoder().encode(wishlist) else { continue }

            try? await db
                .collection("users")
                .document(uid)
                .collection("wishlists")
                .document(wishlist.id)
                .setData(encoded)
        }

        await fetchWishlists()
    }

    // MARK: - Delete Wishlist

    func deleteWishlist(wishlist: Wishlist) async {
        guard let uid = userId else { return }

        try? await db
            .collection("users")
            .document(uid)
            .collection("wishlists")
            .document(wishlist.id)
            .delete()

        await fetchWishlists()
    }
}
