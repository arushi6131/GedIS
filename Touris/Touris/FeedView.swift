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

            // Title and Description
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            .padding([.leading, .trailing, .bottom])
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: 350)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(title: "Sample Title", description: "Sample Description", images: [UIImage(named: "sample_image")!])
    }
}



import SwiftUI

struct FeedView: View {
    @EnvironmentObject var postsViewModel: PostsViewModel
    @State private var imagesDict: [Int: [UIImage]] = [:]
    
    @State private var allItineraries: [Itinerary] = [
        Itinerary(id: 1, name: "Hollywood", description: "An exciting trip to Hollywood!", locations: [Location(name: "Nobu", description: "Peruvian Japanese food!", photos: ["Nobu1"], x: -118.383736, y: 34.052235, rating: 5), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["Universal1"], x: -118.352918, y: 34.137743, rating: 5)]),
        Itinerary(id: 2, name: "Beverly Hills", description: "Beverly Hills Shopping", locations: [Location(name: "Nobu", description: "Peruvian Japanese food!", photos: ["Nobu1"], x: -118.383736, y: 34.052235, rating: 5), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["Universal1"], x: -118.352918, y: 34.137743, rating: 5)])
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(postsViewModel.itineraries + allItineraries) { itinerary in
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
                loadImages(for: postsViewModel.itineraries + allItineraries)
            }
        }
    }

    private func loadImages(for itineraries: [Itinerary]) {
        var newImagesDict = [Int: [UIImage]]()

        for itinerary in itineraries {
            var images: [UIImage] = []
            for location in itinerary.locations {
                for photoName in location.photos {
                    if let image = UIImage(named: photoName) ?? loadImage(named: photoName) {
                        images.append(image)
                    }
                }
            }
            newImagesDict[itinerary.id] = images
        }
        
        self.imagesDict = newImagesDict
    }
    
    private func loadImage(named name: String) -> UIImage? {
        if let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let fileURL = directory.appendingPathComponent("\(name).jpg")
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView().environmentObject(PostsViewModel())
    }
}




struct Itinerary: Identifiable {
    var id: Int
    var name: String
    var description: String
    var locations: [Location]
}

struct Location: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var description: String
    var photos: [String]
    var x: Double
    var y: Double
    var rating: Double?
    var selectedDate: Date?
}




