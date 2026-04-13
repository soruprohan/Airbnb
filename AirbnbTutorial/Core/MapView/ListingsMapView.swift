//
//  ListingsMapView.swift
//  AirbnbTutorial
//

import SwiftUI
import MapKit

struct ListingsMapView: View {
    let listings: [Listing]

    @State private var cameraPosition: MapCameraPosition

    init(listings: [Listing]) {
        self.listings = listings
        self._cameraPosition = State(initialValue: Self.computeRegion(for: listings))
    }

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(listings) { listing in
                Annotation(listing.title, coordinate: CLLocationCoordinate2D(
                    latitude: listing.latitude,
                    longitude: listing.longitude
                )) {
                    NavigationLink(value: listing) {
                        VStack(spacing: 0) {
                            Text("$\(listing.pricePerNight)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.pink)
                                .clipShape(Capsule())

                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(.pink)
                                .offset(y: -2)
                        }
                    }
                }
            }
        }
        .onChange(of: listings) { _, newListings in
            withAnimation {
                cameraPosition = Self.computeRegion(for: newListings)
            }
        }
    }

    // MARK: - Compute region from listings coordinates

    private static func computeRegion(for listings: [Listing]) -> MapCameraPosition {
        guard !listings.isEmpty else {
            // Fallback to a world view if no listings
            return .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
            ))
        }

        let lats = listings.map(\.latitude)
        let lngs = listings.map(\.longitude)

        //Finds the midpoint between the northernmost and southernmost listing (and east/west).
        //This becomes the center of the map
        let centerLat = (lats.min()! + lats.max()!) / 2
        let centerLng = (lngs.min()! + lngs.max()!) / 2

        // Add padding so pins aren't right at the edge
        let spanLat = max(0.02, (lats.max()! - lats.min()!) * 1.4)
        let spanLng = max(0.02, (lngs.max()! - lngs.min()!) * 1.4)

        return .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
            span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLng)
        ))
    }
}

#Preview {
    ListingsMapView(listings: [Listing.example])
}
