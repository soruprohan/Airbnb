//
//  WishlistsView.swift
//  AirbnbTutorial
//
//  Created by sorup rohan on 2/3/26.

//
//  WishlistsView.swift
//  AirbnbTutorial
//

import SwiftUI

struct WishlistsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var wishlistViewModel: WishlistViewModel

    @State private var showLoginSheet = false
    @State private var showCreateSheet = false
    @State private var newWishlistName = ""
    @State private var wishlistToDelete: Wishlist?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if authViewModel.userSession == nil {
                    notLoggedInView
                } else if wishlistViewModel.wishlists.isEmpty {
                    emptyStateView
                } else {
                    wishlistGridView
                }
            }
            .navigationTitle("Wishlists")
            .toolbar {
                if authViewModel.userSession != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showCreateSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) { LoginView() }
            .sheet(isPresented: $showCreateSheet) { createWishlistSheet }
            // Confirm before deleting
            .confirmationDialog(
                "Delete \"\(wishlistToDelete?.name ?? "")\"?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Wishlist", role: .destructive) {
                    guard let wl = wishlistToDelete else { return }
                    Task { await wishlistViewModel.deleteWishlist(wishlist: wl) }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete the wishlist and all saved listings in it.")
            }
            .task {
                if authViewModel.userSession != nil {
                    await wishlistViewModel.fetchWishlists()
                }
            }
        }
    }
}

// MARK: - Sub-views

private extension WishlistsView {

    // ── Not logged in ──────────────────────────────────────────────────
    var notLoggedInView: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Log in to view your wishlists")
                    .font(.headline)
                Text("You can create, view or edit wishlists once you've logged in")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            Button {
                showLoginSheet = true
            } label: {
                Text("Log in")
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 360, height: 48)
                    .background(.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Spacer()
        }
        .padding()
    }

    // ── Empty state ────────────────────────────────────────────────────
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            Text("No wishlists yet")
                .font(.headline)
            Text("Tap + to create your first wishlist")
                .font(.subheadline)
                .foregroundStyle(.gray)
            Spacer()
        }
        .padding(.top, 80)
    }

    // ── Wishlist grid with long-press delete ───────────────────────────
    var wishlistGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(wishlistViewModel.wishlists) { wishlist in
                    NavigationLink(destination: WishlistDetailView(wishlist: wishlist)
                        .environmentObject(wishlistViewModel)
                        .environmentObject(authViewModel)
                    ) {
                        WishlistCardView(wishlist: wishlist)
                    }
                    .buttonStyle(.plain)
                    // Long-press to delete
                    .contextMenu {
                        Button(role: .destructive) {
                            wishlistToDelete = wishlist
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Wishlist", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        // Swipe-to-delete hint text at the bottom
        .safeAreaInset(edge: .bottom) {
            Text("Long-press a wishlist to delete it")
                .font(.caption2)
                .foregroundStyle(.gray)
                .padding(.bottom, 8)
        }
    }

    // ── Create wishlist sheet ──────────────────────────────────────────
    var createWishlistSheet: some View {
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
                    Task { await wishlistViewModel.createWishlist(name: name) }
                } label: {
                    Text("Create")
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
        .presentationDetents([.medium])
    }
}

#Preview {
    WishlistsView()
        .environmentObject(AuthViewModel())
        .environmentObject(WishlistViewModel())
}
