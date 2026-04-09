
//
//  AirbnbTutorialApp.swift
//  AirbnbTutorial
//

import SwiftUI
import FirebaseCore

@main //tells the compiler that this is the entry point of the app
struct AirbnbTutorialApp: App {

    @StateObject var authViewModel = AuthViewModel()
    @StateObject var wishlistViewModel = WishlistViewModel()

    init() {
        // reads GoogleService-Info.plist and connects the app to Firebase project
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
