
//  ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        // userSession is nil → not logged in → show MainTabView anyway,
        // but Profile and Wishlists will show login prompts (handled inside each view).
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
