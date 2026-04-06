
//
//  AirbnbTutorialApp.swift
//  AirbnbTutorial
//

import SwiftUI
import FirebaseCore

@main
struct AirbnbTutorialApp: App {

    @StateObject var authViewModel = AuthViewModel()
    @StateObject var wishlistViewModel = WishlistViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(wishlistViewModel)
        }
    }
}
