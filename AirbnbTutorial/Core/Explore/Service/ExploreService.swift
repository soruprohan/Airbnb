//  ExploreService.swift
//  AirbnbTutorial

import Foundation

class ExploreService {

    private let apiKey  = "bb3ebe7f9fmsh12d45eb0701c154p1987c1jsn31de3749df7f"
    private let apiHost = "airbnb13.p.rapidapi.com"

    //these functions parameters are passed from the search view
    func fetchListings(    
        location: String = "London",  
        startDate: Date? = nil,
        endDate: Date? = nil,
        adults: Int = 1
    ) async throws -> [Listing] {
        let parts = location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let city  = parts.first ?? location // parts.first means first component before the comma, which is usually the city. If there's no comma, we just use the whole location string as the city.
        let state = parts.count > 1 ? parts[1] : "" //If array has more than 1 item -> take second item

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" //API expects dates in this format

        // Use passed-in dates, fall back to today+2 if nil or invalid
        let today = Date()
        let defaultCheckout = Calendar.current.date(byAdding: .day, value: 2, to: today)!

        let resolvedStart = startDate ?? today 
        let resolvedEnd   = (endDate != nil && endDate! > resolvedStart) ? endDate! : defaultCheckout

        let checkin  = formatter.string(from: resolvedStart)
        let checkout = formatter.string(from: resolvedEnd)

        let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? location
        let urlString = "https://\(apiHost)/search-location?location=\(encodedLocation)&checkin=\(checkin)&checkout=\(checkout)&adults=\(max(1, adults))&children=0&infants=0&pets=0&page=1&currency=USD"

        print("DEBUG: Requesting → \(urlString)")

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey,  forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")

        let (data, response) = try await URLSession.shared.data(for: request) //actually fires the network request

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        print("DEBUG: HTTP status → \(statusCode)")

        if let rawString = String(data: data, encoding: .utf8) {
            print("DEBUG: Raw response → \(String(rawString.prefix(800)))") //raw data's first 800 characters print
        }

        guard (200...299).contains(statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try decode(data: data, city: city, state: state)
    }

    // MARK: - Decode

    private func decode(data: Data, city: String, state: String) throws -> [Listing] { //this functions returns an array of listing objects 
        do {
            let decoded = try JSONDecoder().decode(APISearchResponse.self, from: data)
            let listings = (decoded.results ?? [])
                .compactMap { $0.toListing(searchedCity: city, searchedState: state) }
                .filter { !$0.imageURLs.isEmpty }
            print("DEBUG: Decoded \(listings.count) listings successfully")
            return listings
        } catch {
            print("DEBUG: Decode error → \(error)")
            throw error
        }
    }
}
