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
        @State private var selectedCard: Int? // State to hold the selected card index for navigation
     
        var body: some View {
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(1..<21) { index in
                                CardView(title: "Card \(index)")
                                    .background(
                                        NavigationLink(
                                            destination: CardDetailView(title: "Card \(index)"),
                                            tag: index,
                                            selection: $selectedCard
                                        ) { EmptyView() } // Use an empty view as a placeholder
                                    )
                            }
                        }
                        .padding()
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
     
    #Preview {
        FeedView()
    }
     
