import SwiftUI

// TestLocation struct representing a location
struct TestLocation: Identifiable {
    var id = UUID() // Unique identifier
    var name: String
    var description: String
}

struct MyTripView: View {
    // Hardcoded locations as a mutable State variable
    @State private var locations: [TestLocation] = [
        TestLocation(name: "Paris", description: "The city of lights."),
        TestLocation(name: "New York", description: "The Big Apple."),
        TestLocation(name: "Tokyo", description: "A bustling metropolis."),
        TestLocation(name: "Sydney", description: "Famous for its Opera House."),
        TestLocation(name: "London", description: "Home of the British monarchy.")
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(locations) { location in
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .font(.headline)
                        Text(location.description)
                            .font(.subheadline)
                    }
                    .padding()
                }
                .onDelete(perform: deleteLocation) // Enable swipe-to-delete
            }
            .toolbar {
                EditButton() // Add Edit button to toggle delete mode
            }
        }
        .background(Color.blue.edgesIgnoringSafeArea(.all)) // Background color
    }

    // Function to delete a location
    private func deleteLocation(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
    }
}

struct MyTripView_Previews: PreviewProvider {
    static var previews: some View {
        MyTripView()
    }
}
