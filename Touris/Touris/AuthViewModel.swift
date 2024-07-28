import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import SwiftUI
import UIKit

// Define Location and Itinerary types
/*struct Location: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var description: String
    var rating: Double
    var photos: [String] // URLs to photos
}

struct Itinerary: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var locations: [Location]
}*/

// AuthViewModel class
class AuthViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var currentUserID: String?
    @Published var isSignedIn = false
    @Published var allItineraries: [Itinerary] = []
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private let hardcodedEmail = "test@test.com"
    private let hardcodedPassword = "password"
    
    func signIn(email: String, password: String) {
        errorMessage = ""
        
        if email == hardcodedEmail && password == hardcodedPassword {
            self.isSignedIn = true
            self.currentUserID = "hardcodedUserID"
        } else {
            self.errorMessage = "Invalid email or password"
        }
    }
    
    func createAccount(email: String, password: String) {
        errorMessage = ""
        
        if email == hardcodedEmail {
            self.errorMessage = "Email already in use"
        } else {
            self.signIn(email: email, password: password)
        }
    }
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data is nil"])))
            return
        }
        
        let storageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }
    
    /*func saveItinerary(itinerary: Itinerary, completion: @escaping (Result<Void, Error>) -> Void) {
     guard let userId = currentUserID else {
     completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not signed in."])))
     return
     }
     
     do {
     _ = try db.collection("users").document(userId).collection("itineraries").addDocument(from: itinerary)
     completion(.success(()))
     } catch {
     completion(.failure(error))
     }
     }
     
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
     
     func getAllItineraries(completion: @escaping (Result<[Itinerary], Error>) -> Void) {
     db.collection("users").getDocuments { (userSnapshot, error) in
     if let error = error {
     completion(.failure(error))
     } else if let userSnapshot = userSnapshot {
     var allItineraries: [Itinerary] = []
     let dispatchGroup = DispatchGroup()
     
     for userDocument in userSnapshot.documents {
     dispatchGroup.enter()
     self.db.collection("users").document(userDocument.documentID).collection("itineraries").getDocuments { (itinerarySnapshot, error) in
     if let error = error {
     print("Error fetching itineraries for user \(userDocument.documentID): \(error)")
     } else if let itinerarySnapshot = itinerarySnapshot {
     let itineraries = itinerarySnapshot.documents.compactMap { document -> Itinerary? in
     try? document.data(as: Itinerary.self)
     }
     allItineraries.append(contentsOf: itineraries)
     }
     dispatchGroup.leave()
     }
     }
     
     dispatchGroup.notify(queue: .main) {
     self.allItineraries = allItineraries
     completion(.success(allItineraries))
     }
     }
     }
     }
     }
     */
}
