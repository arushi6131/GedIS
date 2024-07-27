
//  AuthViewModel.swift
//  Touris
//
//  Created by Jaysen Gomez on 7/26/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
class AuthViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var currentUserID = Auth.auth().currentUser?.uid
    @Published var isSignedIn = false
    func signIn(email: String, password: String) {
        // Reset error message
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.isSignedIn = true
                self.currentUserID = result?.user.uid
            }
        }
    }
    func createAccount(email: String, password: String) {
        // Reset error message
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
