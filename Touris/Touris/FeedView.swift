//
//  FeedView.swift
//  Touris
//
//  Created by Arushi Goyal on 7/26/24.
//

import Foundation
import SwiftUI

// CardView structure to represent each card
struct CardView: View {
    var title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .frame(maxWidth: 350) // Set a maximum width for the cards
        .padding(.horizontal)
    }
}

// New view to show details of the selected card

struct CardDetailView: View {
    var title: String
    
    var body: some View {
        ZStack {
            VStack {
                // Main content at the top
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white) // Adjust color for better visibility
                    .padding()
                Text("Details about \(title) will be displayed here.")
                    .foregroundColor(.white) // Adjust color for better visibility
                    .padding()
                Spacer() // Push content to the top

                // Floating card at the bottom
                VStack {
                    Text("More Info")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Make it stretch to the edges
                        .background(Color.white) // Background color for the card
                        .cornerRadius(10)
                        .shadow(radius: 5) // Shadow for the floating effect
                    Text("Additional details about \(title) can go here.")
                        .padding()
                }
                .padding()
                .padding(.bottom, 20) // Add bottom padding to float above the bottom edge
            }
        }
        .navigationTitle("Card Details") // Title for the navigation bar
        .navigationBarTitleDisplayMode(.inline) // Inline title display mode
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(title: "Sample Card")
    }
}


// FeedView structure that contains a scrollable list of cards
struct FeedView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(1..<21) { index in
                        NavigationLink(destination: CardDetailView(title: "Card \(index)")) {
                            CardView(title: "Card \(index)")
                        }
                    }
                }
                .padding()
            }
            .background()
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    FeedView()
}

