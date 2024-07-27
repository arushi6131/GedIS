//
//  CardDetailView.swift
//  Touris
//
//  Created by Arushi Goyal on 7/27/24.
//

import Foundation
import SwiftUI

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


