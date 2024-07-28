import SwiftUI
import ArcGIS
import ArcGISToolkit

struct CreatePostView: View {
    @EnvironmentObject var postsViewModel: PostsViewModel
    @State private var selectedLocations: [Location] = []
    @State private var showImagePicker = false
    @State private var showLocationEditor = false
    @State private var currentEditingLocation: Location?
    
    @State private var locationName = ""
    @State private var locationDescription = ""
    @State private var locationRating = ""
    @State private var selectedImages: [UIImage] = []
    @State private var itineraryName = ""
    @State private var itineraryDescription = ""  // New state variable for itinerary description
    
    @StateObject private var locatorDataSource = LocatorSearchSource(
        name: "My Locator",
        maximumResults: 10,
        maximumSuggestions: 5
    )
    
    @State private var viewpoint: Viewpoint? = Viewpoint(
        center: Point(
            x: -118.2426,
            y: 34.0549,
            spatialReference: .wgs84
        ),
        scale: 1e6
    )
    
    @StateObject private var model = ExploreView.Model()
    
    @State private var queryCenter: Point? = nil
    @State private var geoViewExtent: Envelope? = nil
    @State private var isGeoViewNavigating = false
    @State private var calloutPlacement: CalloutPlacement? = nil
    @State private var identifyScreenPoint: CGPoint? = nil
    @State private var identifyTapLocation: Point? = nil
    @State private var xCoordinate: Double = 0.0
    @State private var yCoordinate: Double = 0.0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MapView with callout and search functionality
                ZStack {
                    MapViewReader { proxy in
                        MapView(
                            map: model.map,
                            viewpoint: viewpoint,
                            graphicsOverlays: [model.searchResultsOverlay]
                        )
                        .onSingleTapGesture { screenPoint, tapLocation in
                            identifyScreenPoint = screenPoint
                            identifyTapLocation = tapLocation
                        }
                        .callout(placement: $calloutPlacement.animation()) { placement in
                            VStack {
                                if let attributes = placement.geoElement?.attributes {
                                    Text("\(attributes["PlaceName"] ?? "N/A")")
                                    Text("Address: \(attributes["Place_addr"] ?? "N/A")")
                                    Button(action: {
                                        if let point = placement.geoElement?.geometry as? Point {
                                            addLocation(name: attributes["PlaceName"] as? String ?? "Unknown", x: point.x, y: point.y)
                                        }
                                    }) {
                                        Text("Add Location")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                } else {
                                    Text("Unknown Address")
                                        .padding()
                                }
                            }
                            .padding()
                        }
                        .task(id: identifyScreenPoint) {
                            guard let screenPoint = identifyScreenPoint,
                                  let identifyResult = try? await proxy.identify(
                                    on: model.searchResultsOverlay,
                                    screenPoint: screenPoint,
                                    tolerance: 10
                                  )
                            else {
                                return
                            }
                            calloutPlacement = identifyResult.graphics.first.flatMap { graphic in
                                if let point = graphic.geometry as? Point {
                                    xCoordinate = point.x
                                    yCoordinate = point.y
                                    print("X Coordinate: \(xCoordinate), Y Coordinate: \(yCoordinate)")
                                }
                                return CalloutPlacement.geoElement(graphic, tapLocation: identifyTapLocation)
                            }
                            identifyScreenPoint = nil
                            identifyTapLocation = nil
                        }
                        .overlay {
                            SearchView(
                                sources: [locatorDataSource],
                                viewpoint: $viewpoint
                            )
                            .resultsOverlay(model.searchResultsOverlay)
                            .queryCenter($queryCenter)
                            .geoViewExtent($geoViewExtent)
                            .isGeoViewNavigating($isGeoViewNavigating)
                            .onQueryChanged { query in
                                if query.isEmpty {
                                    calloutPlacement = nil
                                }
                            }
                            .padding()
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                }
                .frame(height: UIScreen.main.bounds.height * 0.4)
                
                // Locations list
                VStack {
                    Text("Selected Locations")
                        .font(.headline)
                        .padding()
                    
                    if selectedLocations.isEmpty {
                        Text("No locations added yet.")
                            .padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(selectedLocations) { location in
                                    VStack(alignment: .leading) {
                                        Text(location.name)
                                            .font(.headline)
                                        Text(location.description)
                                            .font(.subheadline)
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 10) {
                                                ForEach(location.photos, id: \.self) { photoName in
                                                    if let image = loadImage(named: photoName) {
                                                        Image(uiImage: image)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 100, height: 100)
                                                            .clipped()
                                                            .cornerRadius(10)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.vertical, 10)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding(.vertical, 5)
                                    .onTapGesture {
                                        currentEditingLocation = location
                                        locationName = location.name
                                        locationDescription = location.description
                                        locationRating = String(location.rating ?? 5)
                                        selectedImages = location.photos.compactMap { loadImage(named: $0) }
                                        showLocationEditor = true
                                    }
                                }
                            }
                            .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 20)
                    }

                    // New Itinerary Description Field
                    TextField("Itinerary Name", text: $itineraryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    TextField("Itinerary Description", text: $itineraryDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: shareItinerary) {
                        Text("Share Itinerary")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding(.horizontal)
                .frame(height: UIScreen.main.bounds.height * 0.6)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showLocationEditor, onDismiss: saveLocationDetails) {
            locationEditorView
        }
    }
    
    private func addLocation(name: String, x: Double, y: Double) {
        let location = Location(name: name, description: "", photos: [], x: x, y: y, rating: 5)
        selectedLocations.append(location)
    }
    
    private var locationEditorView: some View {
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
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
            
            Button(action: saveLocationDetails) {
                Text("Save Location")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private func saveLocationDetails() {
        guard !locationName.isEmpty, !locationDescription.isEmpty, !locationRating.isEmpty else {
            return
        }
        
        if let currentLocation = currentEditingLocation {
            if let index = selectedLocations.firstIndex(where: { $0.id == currentLocation.id }) {
                selectedLocations[index].name = locationName
                selectedLocations[index].description = locationDescription
                selectedLocations[index].rating = Double(locationRating) ?? 0.0
                selectedLocations[index].photos = selectedImages.compactMap { image in
                    let imageName = UUID().uuidString
                    saveImage(image: image, name: imageName)
                    return imageName
                }
            }
        } else {
            let newLocation = Location(name: locationName, description: locationDescription, photos: selectedImages.compactMap { image in
                let imageName = UUID().uuidString
                saveImage(image: image, name: imageName)
                return imageName
            }, x: xCoordinate, y: yCoordinate, rating: 5)
            selectedLocations.append(newLocation)
        }
        
        resetFields()
    }
    
    private func resetFields() {
        locationName = ""
        locationDescription = ""
        locationRating = ""
        selectedImages = []
        currentEditingLocation = nil
    }
    
    private func shareItinerary() {
        let newItinerary = Itinerary(id: postsViewModel.itineraries.count + 5, name: itineraryName, description: itineraryDescription, locations: selectedLocations)
        postsViewModel.addItinerary(newItinerary)
        
        selectedLocations.removeAll()
        itineraryDescription = ""  // Reset itinerary description
    }
    
    private func saveImage(image: UIImage, name: String) {
        if let data = image.jpegData(compressionQuality: 1.0),
           let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let fileURL = directory.appendingPathComponent("\(name).jpg")
            try? data.write(to: fileURL)
        }
    }
    
    private func loadImage(named name: String) -> UIImage? {
        if let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let fileURL = directory.appendingPathComponent("\(name).jpg")
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
}

struct CreatePostView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePostView()
    }
}

