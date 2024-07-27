import SwiftUI

struct CardView: View {
    var title: String
    var description: String
    var images: [UIImage]

    var body: some View {
        VStack(spacing: 10) {
            // Scrollable Image Section
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 150)
                            .clipped()
                            .cornerRadius(10)
                            .padding(.top)
                    }
                }
                .padding(.horizontal)
            }

            // Description with Profile Picture
            HStack(alignment: .top) {
                Image("profile_picture")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                Text(description)
                    .font(.subheadline)
                    .padding(.bottom)
                    .padding([.leading], 10)
            }
            .padding([.leading, .trailing])
        }
        .frame(maxWidth: 350)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct FeedView: View {
    @State private var allItineraries: [Itinerary] = [
        Itinerary(id: 1, name: "Hollywood", description: "An exciting trip to Hollywood!", locations: [Location(name: "Nobu", description: "Peruvian Japanese food!", photos: ["Nobu1"], x: -118.383736, y: 34.052235), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["Universal1"], x: -118.352918, y: 34.137743)]),
        Itinerary(id: 2, name: "Beverly Hills", description: "Beversly Hills Shopping", locations: [Location(name: "N", description: "Peruvian Japanese food!", photos: ["Nobu1"], x: -118.383736, y: 34.052235), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["Universal1"], x: -118.352918, y: 34.137743)])
    ]
    @State private var imagesDict: [Int: [UIImage]] = [:]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(allItineraries) { itinerary in
                        if let images = imagesDict[itinerary.id] {
                            NavigationLink(destination: CardDetailView(itinerary: itinerary)) {
                                CardView(title: itinerary.name, description: itinerary.description, images: images)
                            }
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                loadImages(for: allItineraries)
            }
        }
    }

    private func loadImages(for itineraries: [Itinerary]) {
        var newImagesDict = [Int: [UIImage]]()

        for itinerary in itineraries {
            var images: [UIImage] = []
            for location in itinerary.locations {
                for photoName in location.photos {
                    if let image = UIImage(named: photoName) {
                        images.append(image)
                    }
                }
            }
            newImagesDict[itinerary.id] = images
        }
        
        self.imagesDict = newImagesDict
    }
}

struct Itinerary: Identifiable {
    var id: Int
    var name: String
    var description: String
    var locations: [Location]
}

struct Location: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var photos: [String]
    var x: Double
    var y: Double
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

