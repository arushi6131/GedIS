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

                Text(description)
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

struct FeedView: View {
    @ObservedObject var authViewModel = AuthViewModel()
    @State private var allItineraries: [Itinerary] = []
    @State private var imagesDict: [String: [UIImage]] = [:]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(allItineraries) { itinerary in
                        ForEach(itinerary.locations) { location in
                            if let images = imagesDict[location.name] {
                                NavigationLink(destination: CardDetailView(title: location.name)) {
                                    CardView(title: location.name, description: location.description, images: images)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                authViewModel.getItineraries { result in
                    switch result {
                    case .success(let itineraries):
                        self.allItineraries = itineraries
                        loadImages(for: itineraries)
                    case .failure(let error):
                        print("Failed to fetch itineraries: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func loadImages(for itineraries: [Itinerary]) {
        var newImagesDict = [String: [UIImage]]()

        let dispatchGroup = DispatchGroup()

        for itinerary in itineraries {
            for location in itinerary.locations {
                dispatchGroup.enter()
                var images: [UIImage] = []

                let locationDispatchGroup = DispatchGroup()

                for photoURL in location.photos {
                    locationDispatchGroup.enter()
                    authViewModel.fetchImage(from: photoURL) { result in
                        switch result {
                        case .success(let image):
                            images.append(image)
                        case .failure(let error):
                            print("Failed to load image: \(error.localizedDescription)")
                        }
                        locationDispatchGroup.leave()
                    }
                }

                locationDispatchGroup.notify(queue: .main) {
                    newImagesDict[location.name] = images
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.imagesDict = newImagesDict
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
