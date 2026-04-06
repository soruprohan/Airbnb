//
//  AuthViewModel.swift
//  AirbnbTutorial
//
//  Created by sorup rohan on 5/3/26.
//

//  AuthViewModel.swift

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class AuthViewModel: ObservableObject {
    
    // The raw Firebase session — nil means logged out
    @Published var userSession: FirebaseAuth.User?
    
    // own app-level user model (fetched from Firestore)
    @Published var currentUser: AppUser?
    
    init() {
        // On launch, restore any existing session automatically
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchCurrentUser()
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = result.user
        await fetchCurrentUser()
    }
    
    // MARK: - Register
    func register(email: String, password: String, fullName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.userSession = result.user
        
        // Save the new user's profile data to Firestore
        let user = AppUser(id: result.user.uid, fullName: fullName, email: email)
        let encodedUser = try Firestore.Encoder().encode(user) //convert swift object to dictionary
        try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
        
        await fetchCurrentUser() //load the saved user back into app state
    }
    
    // MARK: - Sign Out
    func signOut() {
        try? Auth.auth().signOut() //try is for ignoring errors
        self.userSession = nil
        self.currentUser = nil
    }
    
    // MARK: - Fetch User from Firestore
    func fetchCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument() else { return }
        
        self.currentUser = try? snapshot.data(as: AppUser.self) //firestore directly decode document into swift object since it conforms to Codable
    }
}
