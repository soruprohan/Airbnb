
//
//  WishlistPickerView.swift
//  AirbnbTutorial
//

import SwiftUI

struct WishlistPickerView: View {
    let listing: Listing
    @EnvironmentObject var wishlistViewModel: WishlistViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showCreateSheet = false
    @State private var newWishlistName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(wishlistViewModel.wishlists) { wishlist in
                        Button {
                            Task {
                                if wishlist.listingIds.contains(listing.id) {
                                    await wishlistViewModel.removeFromSpecificWishlist(
                                        listingId: listing.id,
                                        wishlistId: wishlist.id
                                    )
                                } else {
                                    await wishlistViewModel.addToSpecificWishlist(
                                        listing: listing,
                                        wishlistId: wishlist.id
                                    )
                                }
                                dismiss()
                            }
                        } label: {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.pink)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(wishlist.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    Text("\(wishlist.listingIds.count) saved")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }

                                Spacer()

                                if wishlist.listingIds.contains(listing.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.pink)
                                        .font(.title3)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    Button {
                        showCreateSheet = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray3), lineWidth: 1.5)
                                    .frame(width: 56, height: 56)
                                Image(systemName: "plus")
                                    .foregroundStyle(.primary)
                                    .font(.title3)
                            }
                            Text("New wishlist")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Save to wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                createAndSaveSheet
            }
        }
    }

    private var createAndSaveSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TextField("Wishlist name", text: $newWishlistName)
                    .font(.title3)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)

                Button {
                    guard !newWishlistName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    let name = newWishlistName
                    newWishlistName = ""
                    showCreateSheet = false
                    Task {
                        await wishlistViewModel.createWishlist(name: name, addListing: listing)
                        dismiss()
                    }
                } label: {
                    Text("Create & Save")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("New Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCreateSheet = false }
                }
            }
        }
        .presentationDetents([.medium]) //take 50% of the screen height when it appears
    }
}
