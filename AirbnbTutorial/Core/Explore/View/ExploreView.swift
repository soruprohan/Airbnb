//
//  ExploreView.swift
//  AirbnbTutorial


import SwiftUI

struct ExploreView: View {
    @State private var showDestinationSearchView = false
    @ObservedObject var viewModel: ExploreViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookingViewModel: BookingViewModel

    var body: some View {
        NavigationStack {
            if showDestinationSearchView {
                DestinationSearchView(show: $showDestinationSearchView, viewModel: viewModel)
            } else {
                contentView
            }
        }
    }

    // MARK: - Main content

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            SearchAndFilterBar(location: $viewModel.searchLocation)
                .onTapGesture {
                    withAnimation(.snappy) {
                        showDestinationSearchView.toggle()
                    }
                }

            if viewModel.isLoading {
                loadingView
            } else if viewModel.listings.isEmpty && viewModel.errorMessage == nil {
                emptyView
            } else {
                listingsGrid
            }
        }
        .navigationDestination(for: Listing.self) { listing in
            ListingDetailView(listing: listing)
                .navigationBarBackButtonHidden()
                .environmentObject(viewModel)
                .environmentObject(authViewModel)
                .environmentObject(bookingViewModel)
        }
        .alert("Something went wrong",
               isPresented: Binding(
                   get: { viewModel.errorMessage != nil },
                   set: { if !$0 { viewModel.errorMessage = nil } }
               )) {
            Button("Retry") { Task { await viewModel.fetchListings() } }
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Finding listings...")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Empty state

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.gray)
            Text("No listings found")
                .font(.headline)
            Text("Try a different location")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Listings grid

    private var listingsGrid: some View {
        LazyVStack(spacing: 32) {
            ForEach(viewModel.listings) { listing in
                NavigationLink(value: listing) {
                    ListingItemView(listing: listing)
                        .frame(height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .environmentObject(viewModel)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ExploreView(viewModel: ExploreViewModel(service: ExploreService()))
        .environmentObject(AuthViewModel())
        .environmentObject(BookingViewModel())
}
