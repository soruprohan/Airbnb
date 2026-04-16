//  StayCardView.swift
//  AirbnbTutorial

import SwiftUI

struct StayCardView: View {
    let listing: Listing

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var wishlistViewModel: WishlistViewModel
    @EnvironmentObject var exploreViewModel: ExploreViewModel

    @State private var showLoginSheet = false
    @State private var showWishlistPicker = false

    private var isSaved: Bool {
        wishlistViewModel.savedListingIds.contains(listing.id)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                CardView(listing: listing)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                heartButton
                    .padding(12)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(listing.city) \(listing.state)")
                        .fontWeight(.bold)
                        .foregroundStyle(.black)

                    // Replaced "12 mi away" with listing type
                    Text("Entire \(listing.type.description)")
                        .foregroundStyle(.gray)

                    // Replaced "Nov 3 - 10" with real selected dates
                    if let dateRange = exploreViewModel.formattedDateRange {
                        Text(dateRange)
                            .foregroundStyle(.gray)
                    }

                    HStack(spacing: 4) {
                        Text("৳\(listing.pricePerNight)")
                            .fontWeight(.semibold)
                        Text("night")
                    }
                    .foregroundStyle(.black)
                }

                Spacer()

                // Fixed rating format — was showing too many decimals
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                    Text(listing.rating > 0 ? String(format: "%.2f", listing.rating) : "New")
                }
                .foregroundStyle(.black)
            }
            .font(.footnote)
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
                .environmentObject(authViewModel) //added environment object so LoginView can update auth state
        }
        .sheet(isPresented: $showWishlistPicker) {
            WishlistPickerView(listing: listing)
                .environmentObject(wishlistViewModel)
        }
    }

    private var heartButton: some View {
        Button {
            if authViewModel.userSession == nil {
                showLoginSheet = true
            } else {
                showWishlistPicker = true
            }
        } label: {
            Image(systemName: isSaved ? "heart.fill" : "heart")
                .font(.system(size: 22))
                .foregroundStyle(isSaved ? .blue : .white)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
        }
    }
}

#Preview {
    StayCardView(listing: Listing.example)
        .environmentObject(AuthViewModel())
        .environmentObject(WishlistViewModel())
        .environmentObject(ExploreViewModel(service: ExploreService()))
}

// MARK: - CardView (image carousel for listing cards)

struct CardView: View {
    let listing: Listing

    var body: some View {
        TabView {
            ForEach(listing.imageURLs, id: \.self) { urlString in
                if let url = URL(string: urlString), urlString.hasPrefix("http") {
                    // ── Remote image from API ───────────────────────
                    AsyncImage(url: url) { phase in //SwiftUI's built-in async image loader
                        switch phase {              //phase represents the current loading state.
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            placeholderView
                        case .empty:  //Image is still loading
                            ZStack {
                                Color(.systemGray6)
                                ProgressView()
                            }
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    // ── Local asset (fallback) ───
                    Image(urlString)
                        .resizable()
                        .scaledToFill()
                }
            }
        }
        .tabViewStyle(.page)
    }

    private var placeholderView: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
        }
    }
}

#Preview("CardView") {
    CardView(listing: Listing.example)
        .frame(height: 320)
}
