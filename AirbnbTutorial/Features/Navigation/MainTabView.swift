//  MainTabView.swift
//  AirbnbTutorial

import SwiftUI

struct MainTabView: View {
    @StateObject var exploreViewModel = ExploreViewModel(service: ExploreService())
    @StateObject var bookingViewModel = BookingViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            ExploreView(viewModel: exploreViewModel)
                .environmentObject(authViewModel)
                .environmentObject(bookingViewModel)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }

            NavigationStack {
                ListingsMapView(listings: exploreViewModel.listings)
                    .navigationTitle("Map")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: Listing.self) { listing in
                        StayOverviewView(listing: listing)
                            .navigationBarBackButtonHidden()
                            .environmentObject(exploreViewModel)
                            .environmentObject(authViewModel)
                            .environmentObject(bookingViewModel)
                    }
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            WishlistsView()
                .environmentObject(exploreViewModel)
                .environmentObject(authViewModel)
                .environmentObject(bookingViewModel)
                .tabItem {
                    Label("Wishlists", systemImage: "heart")
                }

            TripsView()
                .environmentObject(bookingViewModel)
                .tabItem {
                    Label("Trips", systemImage: "suitcase")
                }

            ProfileView()
                .environmentObject(bookingViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
