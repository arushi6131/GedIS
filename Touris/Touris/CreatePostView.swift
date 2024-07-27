import SwiftUI

struct CreatePostView: View {
    @State private var locationName = ""
    @State private var locationDescription = ""
    @State private var locationRating = ""
    @State private var selectedImage: UIImage? = nil
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
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            } else {
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    Text("Select Photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
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
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .padding()
    }
    
    private func savePost() {
        guard let image = selectedImage else {
            authViewModel.errorMessage = "Please select an image."
            return
        }
        
        guard let rating = Double(locationRating) else {
            authViewModel.errorMessage = "Please enter a valid rating."
            return
        }
        
        authViewModel.uploadPhoto(image: image) { result in
            switch result {
            case .success(let photoURL):
                let location = Location(name: locationName, description: locationDescription, rating: rating, photos: [photoURL])
                let itinerary = Itinerary(title: "New Itinerary", locations: [location])
                
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

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePostView()
    }
}



