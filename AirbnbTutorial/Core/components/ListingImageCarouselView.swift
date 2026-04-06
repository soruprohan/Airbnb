//
//  ListingImageCarouselView.swift
//  AirbnbTutorial
//
//  Created by sorup rohan on 1/3/26.
//

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
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            placeholderView
                        case .empty:
                            ZStack {
                                Color(.systemGray6)
                                ProgressView()
                            }
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    // ── Local asset (DeveloperPreview / fallback) ───
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
    ListingImageCarouselView(listing: DeveloperPreview.shared.listings[0])
        .frame(height: 320)
}
