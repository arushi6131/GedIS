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
                        Image(systemName: "map")
                        Text("Feed")
                    }
                CreatePostView()
                    .tabItem {
                        Image(systemName: "plus.app")
                        Text("Create Post")
                    }
            ExploreView()
                .tabItem {
                    Image(systemName: "mappin")
                    Text("Explore")
                }
                MyTripView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("My Trip")
                    }
            }
        }
    }
}

#Preview {
    MainView()
}
