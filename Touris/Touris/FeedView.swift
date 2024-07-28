import SwiftUI

struct CardView: View {
    var title: String
    var description: String
    var images: [UIImage]
    var likeCount: Int = 0
    var commentCount: Int = 0
    var profileImage: UIImage?

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
            
            // Title and Description with Profile Picture
            HStack {
                // Profile Picture
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .padding()
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                .padding([.leading, .trailing])
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            // Like and Comment Icons with Counts
            HStack {
                Image(systemName: "heart")
                    .foregroundColor(.red)
                Text("\(likeCount)")
                
                Image(systemName: "bubble.right")
                    .foregroundColor(.blue)
                Text("\(commentCount)")
                
                Spacer()
            }
            .padding()
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



struct FeedView: View {
    @EnvironmentObject var postsViewModel: PostsViewModel
    @State private var imagesDict: [Int: [UIImage]] = [:]
    
    @State private var allItineraries: [Itinerary] = [
        Itinerary(id: 1, name: "Hollywood", description: "An exciting trip to Hollywood!", locations: [Location(name: "Walk of Fame", description: "Looking at the walk of fame stars!", photos: ["sas4", "sas3"], x: -118.383736, y: 34.052235, rating: 5), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["Universal1"], x: -118.352918, y: 34.137743, rating: 5)], likeCount:35, commentCount:5, profilePicture: UIImage(named: "dan")),
        Itinerary(id: 2, name: "Beverly Hills", description: "Beverly Hills Shopping", locations: [Location(name: "Rodeo Drive", description: "Most Expensive Shopping place in the world", photos: ["sas1","sas2"], x: -118.383736, y: 34.052235, rating: 5), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["sas5"], x: -118.352918, y: 34.137743, rating: 5)], likeCount:75, commentCount:9, profilePicture: UIImage(named: "aru")),
        Itinerary(id: 3, name: "Santa Monica", description: "A fun day at the beach!", locations: [Location(name: "Rodeo Drive", description: "Most Expensive Shopping place in the world", photos: ["Nobu1"], x: -118.383736, y: 34.052235, rating: 5), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["feedimg1"], x: -118.352918, y: 34.137743, rating: 5)], likeCount:53, commentCount:1, profilePicture: UIImage(named: "sas")),
        Itinerary(id: 4, name: "Inglewood", description: "Adventure in Inglewood", locations: [Location(name: "Rodeo Drive", description: "Most Expensive Shopping place in the world", photos: ["feedimg2","Nobu1"], x: -118.383736, y: 34.052235, rating: 5), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["Universal1"], x: -118.352918, y: 34.137743, rating: 5)], likeCount:66, commentCount:8, profilePicture: UIImage(named: "profile_picture")),
        Itinerary(id: 5, name: "Pasadena", description: "Road Trip to Pasadena!", locations: [Location(name: "Rodeo Drive", description: "Most Expensive Shopping place in the world", photos: ["feedim3","Nobu1"], x: -118.383736, y: 34.052235, rating: 5), Location(name: "Universal Studios", description: "Theme park with the family", photos: ["Universal1"], x: -118.352918, y: 34.137743, rating: 5)], likeCount:120, commentCount:2, profilePicture: UIImage(named: "Arno"))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(postsViewModel.itineraries + allItineraries) { itinerary in
                        if let images = imagesDict[itinerary.id] {
                            NavigationLink(destination: CardDetailView(itinerary: itinerary)) {
                                CardView(
                                    title: itinerary.name,
                                    description: itinerary.description,
                                    images: images,
                                    likeCount: itinerary.likeCount ?? 0,
                                    commentCount: itinerary.commentCount ?? 0,
                                    profileImage: itinerary.profilePicture
                                )
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
    var likeCount: Int?
    var commentCount: Int?
    var profilePicture: UIImage?
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
