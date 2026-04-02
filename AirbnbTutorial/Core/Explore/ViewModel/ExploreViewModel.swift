//  ExploreViewModel.swift
//  AirbnbTutorial

import Foundation

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var listings = [Listing]()
    @Published var searchLocation = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Dates & guests now live here so all views can read them
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
    @Published var numGuests: Int = 1

    private let service: ExploreService

    init(service: ExploreService) {
        self.service = service
        Task { await fetchListings() }
    }

    // MARK: - Fetch

    func fetchListings(location: String = "London") async {
        isLoading = true
        errorMessage = nil
        do {
            self.listings = try await service.fetchListings(
                location: location,
                startDate: startDate,
                endDate: endDate,
                adults: numGuests
            )
        } catch {
            self.errorMessage = "Couldn't load listings. Check your connection and try again."
            print("DEBUG: fetchListings error — \(error.localizedDescription)")
        }
        isLoading = false
    }

    // MARK: - Search / filter

    func updateListingsForLocation() {
        let trimmed = searchLocation.trimmingCharacters(in: .whitespaces)
        let query = trimmed.isEmpty ? "London" : trimmed
        Task { await fetchListings(location: query) }
    }

    // MARK: - Formatted date strings for display

    var formattedDateRange: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: startDate)

        formatter.dateFormat = "d"
        let endDay = formatter.string(from: endDate)

        // Only show if end is after start
        guard endDate > startDate else { return nil }
        return "\(start) - \(endDay)"
    }
}
