import SwiftUI


struct CreatePostView: View {
    @State private var locationName = ""
    @State private var locationDescription = ""
    @State private var locationRating = ""
    @State private var selectedImages: [UIImage] = [] // Changed to an array for multiple images
    @State private var showImagePicker = false
    @State private var itineraries: [MyItinerary] = [] // Local storage for itineraries
    
    var body: some View {
        VStack {
            TextField("Location Name", text: $locationName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Description", text: $locationDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Rating", text: $locationRating)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.decimalPad)

            // Display selected images
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding(5)
                            .cornerRadius(10)
                    }
                }
            }
            
            Button(action: {
                showImagePicker.toggle()
            }) {
                Text("Select Photos")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $selectedImages)
            }
            
            Button(action: {
                savePost()
            }) {
                Text("Save Post")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            // Reset button
            Button(action: {
                resetFields()
            }) {
                Text("Reset")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private func savePost() {
        guard !selectedImages.isEmpty else {
            // Handle error
            print("Please select at least one image.")
            return
        }
        
        guard let rating = Double(locationRating) else {
            // Handle error
            print("Please enter a valid rating.")
            return
        }
        
        // Create location and itinerary objects
        let location = MyLocation(id: UUID().uuidString, name: locationName, description: locationDescription, rating: rating, photos: selectedImages)
        let itinerary = MyItinerary(id: UUID().uuidString, title: "New Itinerary", locations: [location])
        
        // Save the itinerary to the local array
        itineraries.append(itinerary)
        
        print("Post successfully saved!")
        // Optionally, handle further processing or UI updates here
    }
    
    // Function to reset all fields
    private func resetFields() {
        locationName = ""
        locationDescription = ""
        locationRating = ""
        selectedImages = [] // Reset selected images
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePostView()
    }
}

// Dummy models for MyLocation and MyItinerary
struct MyLocation: Identifiable {
    var id: String
    var name: String
    var description: String
    var rating: Double
    var photos: [UIImage]
}

struct MyItinerary: Identifiable {
    var id: String
    var title: String
    var locations: [MyLocation]
}
