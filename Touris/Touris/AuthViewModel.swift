
//  AuthViewModel.swift
//  Touris
//
//  Created by Jaysen Gomez on 7/26/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

struct Location: Codable {
    var name: String
    var description: String
    var rating: Double
    var photos: [String] // URLs to photos
}

struct Itinerary: Codable {
    var title: String
    var locations: [Location]
}


class AuthViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var currentUserID = Auth.auth().currentUser?.uid
    @Published var isSignedIn = false
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

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
            } else {
                // Sign in the user after successful account creation
                self.signIn(email: email, password: password)
            }
        }
    }
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data is nil"])))
            return
        }
        
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imagesRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                imagesRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }
    
    // Save itinerary for the logged-in user
    func saveItinerary(itinerary: Itinerary, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserID else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not signed in."])))
            return
        }
        
        do {
            let document = try db.collection("users").document(userId).collection("itineraries").addDocument(from: itinerary)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // Retrieve all itineraries for the logged-in user
    func getItineraries(completion: @escaping (Result<[Itinerary], Error>) -> Void) {
        guard let userId = currentUserID else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not signed in."])))
            return
        }
        
        db.collection("users").document(userId).collection("itineraries").getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let itineraries = snapshot.documents.compactMap { document -> Itinerary? in
                    try? document.data(as: Itinerary.self)
                }
                completion(.success(itineraries))
            }
        }
    }

    // Fetch image from Firebase Storage
    func fetchImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let storageRef = storage.reference(forURL: url)
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image."])))
            }
        }
    }
}

