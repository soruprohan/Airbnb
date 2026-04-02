//
//  WishlistCardView.swift
//  AirbnbTutorial
//
//  Created by sorup rohan on 5/3/26.
//

//
//  WishlistCardView.swift
//  AirbnbTutorial
//

import SwiftUI

struct WishlistCardView: View {
    let wishlist: Wishlist

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder icon – replace with an AsyncImage thumbnail later (Phase 4)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fit)

                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.pink)
            }

            Text(wishlist.name)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text("\(wishlist.listingIds.count) saved")
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
}
