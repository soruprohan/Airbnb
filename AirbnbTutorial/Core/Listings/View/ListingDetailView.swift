//
//  ListingDetailView.swift
//  AirbnbTutorial
//
//  Created by sorup rohan on 1/3/26.
//

//
//  ListingDetailView.swift
//  AirbnbTutorial
//

import SwiftUI
import MapKit
import CoreLocation

struct ListingDetailView: View {
    @EnvironmentObject var exploreViewModel: ExploreViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookingViewModel: BookingViewModel
    @Environment(\.dismiss) var dismiss
    let listing: Listing
    @State private var cameraPosition: MapCameraPosition

    init(listing: Listing) { //A initiliazer is needed here because we need to set the initial camera position based on the listing's coordinates
        self.listing = listing

        // Use real coordinates from the listing 
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: listing.latitude,
                longitude: listing.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //zoom level
        )
        self._cameraPosition = State(initialValue: .region(region)) //to access a state variable in an initializer, we need to use the underscore syntax and assign to the State wrapper itself, not the wrapped value. This sets the initial camera position to be centered on the listing's location when the view first appears.
    }

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                ListingImageCarouselView(listing: listing)
                    .frame(height: 320)

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                        .background {
                            Circle()
                                .fill(.white)
                                .frame(width: 32, height: 32)
                        }
                        .padding(32)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title)
                    .font(.title)
                    .fontWeight(.semibold)

                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                        Text(listing.rating > 0 ? String(format: "%.2f", listing.rating) : "New")
                        if listing.rating > 0 {
                            Text(" · ")
                            Text("Reviews")
                                .underline()
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.black)
                    Text("\(listing.city) \(listing.state)")
                }
                .font(.caption)
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Host info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Entire \(listing.type.description) hosted by \(listing.ownerName)")
                        .font(.headline)
                        .frame(width: 250, alignment: .leading)

                    HStack(spacing: 2) {
                        Text("\(listing.numberOfGuests) guests ·")
                        Text("\(listing.numberOfBedrooms) bedrooms ·")
                        Text("\(listing.numberOfBeds) beds ·")
                        Text("\(listing.numberOfBathrooms) baths")
                    }
                    .font(.caption)
                }
                .frame(width: 300, alignment: .leading)

                Spacer()

                hostAvatarView  //A struct that is defined below as a computed property to handle both remote URLs and local asset names for the host's profile picture.
            }
            .padding()

            Divider()

            // Features
            VStack(alignment: .leading, spacing: 16) {
                ForEach(listing.features) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: feature.imageName)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(feature.title)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            Text(feature.subtitle)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                }
            }
            .padding()

            Divider()

            // Bedrooms
            VStack(alignment: .leading, spacing: 16) {
                Text("Where you'll sleep")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(1...max(1, listing.numberOfBedrooms), id: \.self) { bedroom in
                            VStack {
                                Image(systemName: "bed.double")
                                Text("Bedroom \(bedroom)")
                            }
                            .frame(width: 132, height: 100)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
            }
            .padding()

            Divider()

            // Amenities
            VStack(alignment: .leading, spacing: 16) {
                Text("What this place offers")
                    .font(.headline)

                ForEach(listing.amenities) { amenity in
                    HStack {
                        Image(systemName: amenity.imageName)
                            .frame(width: 32)
                        Text(amenity.title)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            .padding()

            Divider()

            // Map
            VStack(alignment: .leading, spacing: 16) {
                Text("Where you'll be")
                    .font(.headline)

                Map(position: $cameraPosition) {
                    Annotation("", coordinate: CLLocationCoordinate2D(
                        latitude: listing.latitude,
                        longitude: listing.longitude
                    )) {
                        ZStack {
                            Circle()
                                .fill(.pink.opacity(0.2))
                                .frame(width: 48, height: 48)
                            Circle()
                                .fill(.white)
                                .frame(width: 32, height: 32)
                                .shadow(radius: 4)
                            Image(systemName: "house.fill")
                                .foregroundStyle(.pink)
                                .font(.system(size: 14))
                        }
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .toolbar(.hidden, for: .tabBar)  //hides the bottom navigation bar
        .ignoresSafeArea()  //allows the content to extend to the edges of the screen
        .padding(.bottom, 64)
        .overlay(alignment: .bottom) { //reservebar Pinned to the bottom of the screen using .overlay.
            reserveBar
        }
    }

    // MARK: - Host avatar (handles both remote URL and local asset)

    @ViewBuilder
    private var hostAvatarView: some View {
        if let url = URL(string: listing.ownerImageUrl), listing.ownerImageUrl.hasPrefix("http") {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())
        } else {
            Image(listing.ownerImageUrl.isEmpty ? "male-profile-photo" : listing.ownerImageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
        }
    }

    // MARK: - Reserve bar

    @State private var showBookingSheet = false
    @State private var showLoginSheet = false

    private var reserveBar: some View {
        VStack {
            Divider().padding(.bottom)
            HStack {
                VStack(alignment: .leading) {
                    Text("$\(listing.pricePerNight)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Total before taxes")
                        .font(.footnote)
                    if let dateRange = exploreViewModel.formattedDateRange {
                        Text(dateRange)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .underline()
                    } else {
                        Text("Add dates")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
                Button {
                    handleReserve()
                } label: {
                    Text("Reserve")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 140, height: 40)
                        .background(.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 32)
        }
        .background(.white)
        .sheet(isPresented: $showBookingSheet) {
            BookingConfirmationView(listing: listing)
                .environmentObject(exploreViewModel)
                .environmentObject(authViewModel)
                .environmentObject(bookingViewModel)
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
                .environmentObject(authViewModel)
        }
    }

    private func handleReserve() {
        // check auth
        if AuthViewModel().userSession == nil { //There's a bug here — AuthViewModel() creates a brand new instance instead of using the injected authViewModel from the environment. A fresh instance always has userSession = nil, so this check will always show the login sheet even when the user is logged in. To fix this, we need to use the injected authViewModel from the environment, not create a new one. So it should be: if authViewModel.userSession == nil { ... }
            showLoginSheet = true
            return
        }
        // check dates
        guard exploreViewModel.endDate > exploreViewModel.startDate else {
            return
        }
        showBookingSheet = true
    }
}

#Preview {
    ListingDetailView(listing: DeveloperPreview.shared.listings[3])
        .environmentObject(ExploreViewModel(service: ExploreService()))
}
