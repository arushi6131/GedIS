import SwiftUI
import Firebase

@main
struct TourisApp: App {
    // Initialize Firebase in the app initializer
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
