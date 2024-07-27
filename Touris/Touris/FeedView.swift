import Foundation
import SwiftUI

// CardView structure to represent each card
struct CardView: View {
    var title: String

    var body: some View {
        VStack(spacing: 10) {
            // Scrollable Image Section
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(1..<4) { imageIndex in
                        Image("feedimg\(imageIndex)") // Replace with your image names
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 150) // Set appropriate width and height
                            .clipped()
                            .cornerRadius(10)
                            .padding(.top)
                    }
                }
                .padding(.horizontal)
            }

            // Description with Profile Picture
            HStack(alignment: .top) {
                Image("profile_picture") // Replace with your profile picture image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40) // Size of the profile picture
                    .clipShape(Circle()) // Make it circular

                Text("Details about \(title). This is a description of the trip and other info posted by the user")
                    .font(.subheadline)
                    .padding(.bottom)
                    .padding([.leading], 10) // Add some padding to the left of the description
            }
            .padding([.leading, .trailing]) // Add padding to the HStack
        }
        .frame(maxWidth: 350) // Set a maximum width for the cards
        .background(Color.white) // Card background
        .cornerRadius(10) // Card corner radius
        .shadow(radius: 5) // Card shadow
        .padding(.horizontal)
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
        }
    }
}

#Preview {
    FeedView()
}
