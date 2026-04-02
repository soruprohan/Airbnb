//
//  WishlistDetailView.swift
//  AirbnbTutorial
//

import SwiftUI

struct WishlistDetailView: View {
    let wishlist: Wishlist
    @EnvironmentObject var exploreViewModel: ExploreViewModel
    @EnvironmentObject var wishlistViewModel: WishlistViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookingViewModel: BookingViewModel

    var body: some View {
        ScrollView {
            if wishlist.savedListings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 48))
                        .foregroundStyle(.gray)
                    Text("Nothing saved here yet")
                        .font(.headline)
                    Text("Heart a listing on the Explore tab to save it here")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 80)
            } else {
                LazyVStack(spacing: 32) {
                    ForEach(wishlist.savedListings) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)
                            .environmentObject(exploreViewModel)
                            .environmentObject(authViewModel)
                            .environmentObject(bookingViewModel)
                        ) {
                            ListingItemView(listing: listing)
                                .padding(.horizontal)
                                .environmentObject(exploreViewModel)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(wishlist.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
