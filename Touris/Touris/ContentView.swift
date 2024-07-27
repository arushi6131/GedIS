//
//  ContentView.swift
//  Touris
//
//  Created by Arushi Goyal on 7/26/24.
//

import SwiftUI

struct ContentView: View {
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
    ContentView()
}
