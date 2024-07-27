import SwiftUI

struct CreatePostView: View {
    @State private var locationName = ""
    @State private var locationDescription = ""
    @State private var locationRating = ""
    @State private var selectedImages: [UIImage] = [] // Changed to an array for multiple images
    @State private var showImagePicker = false
    @ObservedObject var authViewModel = AuthViewModel()
    
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(images: $selectedImages)
        }
        .padding()
    }
    
    private func savePost() {
        guard !selectedImages.isEmpty else {
            authViewModel.errorMessage = "Please select at least one image."
            return
        }
        
        guard let rating = Double(locationRating) else {
            authViewModel.errorMessage = "Please enter a valid rating."
            return
        }
        
        // Process each image
        for image in selectedImages {
            authViewModel.uploadPhoto(image: image) { result in
                switch result {
                case .success(let photoURL):
                    let location = Location(id: UUID().uuidString, name: locationName, description: locationDescription, rating: rating, photos: [photoURL])
                    let itinerary = Itinerary(id: UUID().uuidString, title: "New Itinerary", locations: [location])
                    
                    authViewModel.saveItinerary(itinerary: itinerary) { result in
                        switch result {
                        case .success():
                            print("Post successfully saved!")
                        case .failure(let error):
                            authViewModel.errorMessage = "Error saving post: \(error.localizedDescription)"
                        }
                    }
                case .failure(let error):
                    authViewModel.errorMessage = "Error uploading photo: \(error.localizedDescription)"
                }
            }
        }
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
