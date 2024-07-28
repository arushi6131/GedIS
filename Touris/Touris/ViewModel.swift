import SwiftUI

class PostsViewModel: ObservableObject {
    @Published var itineraries: [Itinerary] = []

    func addItinerary(_ itinerary: Itinerary) {
        itineraries.append(itinerary)
    }
}

