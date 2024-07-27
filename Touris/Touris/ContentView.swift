import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                MainView()
            } else {
                SignInView(authViewModel: authViewModel)
            }
        }
        .onAppear {
            authViewModel.currentUserID = Auth.auth().currentUser?.uid
            authViewModel.isSignedIn = authViewModel.currentUserID != nil
        }
    }
}

#Preview {
    ContentView()
}

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(spacing: 0) {
            HeaderView() // Include the header at the top
            TabView {
                FeedView()
                    .tabItem {
                        Image(systemName: "phone.fill")
                        Text("Feed")
                    }
                CreatPostView()
                    .tabItem {
                        Image(systemName: "tv.fill")
                        Text("Create Post")
                    }
                MyTripView()
                    .tabItem {
                        Image(systemName: "tv.fill")
                        Text("My Trip")
                    }
                ExploreView()
                    .tabItem {
                        Image(systemName: "tv.fill")
                        Text("Explore")
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
