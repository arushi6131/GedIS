import SwiftUI
import ArcGIS
import ArcGISToolkit

struct CreatePostView: View {
    @State private var itineraries: [MyItinerary] = []
    @State private var selectedLocations: [MyLocation] = []
    @State private var showImagePicker = false
    @State private var showLocationEditor = false
    @State private var currentEditingLocation: MyLocation?
    
    @State private var locationName = ""
    @State private var locationDescription = ""
    @State private var locationRating = ""
    @State private var selectedImages: [UIImage] = []
    
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
                                                ForEach(location.photos, id: \.self) { image in
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipped()
                                                        .cornerRadius(10)
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
                                        locationRating = String(location.rating)
                                        selectedImages = location.photos
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
        let location = MyLocation(id: UUID().uuidString, name: name, description: "", rating: 0.0, photos: [], x: x, y: y)
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
                selectedLocations[index].photos = selectedImages
            }
        } else {
            let newLocation = MyLocation(id: UUID().uuidString, name: locationName, description: locationDescription, rating: Double(locationRating) ?? 0.0, photos: selectedImages, x: xCoordinate, y: yCoordinate)
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
        let newItinerary = MyItinerary(id: UUID().uuidString, title: "New Itinerary", locations: selectedLocations)
        itineraries.append(newItinerary)
        
        selectedLocations.removeAll()
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
    var x: Double
    var y: Double
}

struct MyItinerary: Identifiable {
    var id: String
    var title: String
    var locations: [MyLocation]
}


struct CardPostView: View {
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
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

