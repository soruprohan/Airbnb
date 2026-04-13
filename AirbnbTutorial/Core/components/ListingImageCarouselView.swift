
//
//  ListingImageCarouselView.swift
//  AirbnbTutorial
//

import SwiftUI

struct ListingImageCarouselView: View {
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

#Preview {
    ListingImageCarouselView(listing: Listing.example)
        .frame(height: 320)
}
