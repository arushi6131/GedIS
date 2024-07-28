import SwiftUI
import ArcGIS

// Define the predefined locations
let predefinedLocations = [
    (name: "Beverly Hills", description: "A beautiful city known for its upscale shops and celebrity homes.", x: 34.073620, y: -118.400356),
    (name: "Hollywood Sign", description: "An iconic landmark and American cultural symbol.", x: 34.134115, y: -118.321548),
    (name: "Santa Monica", description: "A beachfront city known for its pier and beautiful coastline.", x: 34.019454, y: -118.491191)
]

class Model1: ObservableObject {
    @Published var routeDetails: String = ""
    @Published var selectedStops: [Stop] = []
    @Published var errorMessage: String?

    private let geocoder = LocatorTask(url: URL(string: "https://geocode-api.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
    let map: Map
    let routeGraphic: Graphic
    let routeGraphicsOverlay = GraphicsOverlay()
    let routeTask = RouteTask(url: URL(string: "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")!)

    init() {
        ArcGISEnvironment.apiKey = APIKey("AAPTxy8BH1VEsoebNVZXo8HurIbugLj0NokW51A8J4YONQQOoup_ic4-zcPZFptr5MO1qONslZW2oOIKPyLYoAGjTDzY12Rl5VEQcBLTKAR4d6APiBpXCXAnlltp56ASvOYdKtwJWhW2LPAgTE0ZzQS3B1ub-B_RJf5uTJTG1BYRbHaNe407xxkNjvSCwVWQtxa1otvJLFZALkaCSlW-j3bR0253tW3a6z9vDrfpQKzQH1t6ivQKa5vJkqe0cNhnEnCUAT1_lQ5ndSQI")
        let customBasemapURL = URL(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=0dd3259879ab43e79a9f878e2febf1a2")!
        let customBasemap = Basemap(url: customBasemapURL)
        self.map = Map(basemap: customBasemap!)
        self.map.initialViewpoint = Viewpoint(latitude: 34.052235, longitude: -118.243683, scale: 144447.638572) // Centered around LA
        let symbol = SimpleLineSymbol(style: .solid, color: .systemBlue, width: 4)
        self.routeGraphic = Graphic(geometry: nil, symbol: symbol)
        
        // Add predefined locations as stops
        addPredefinedStops()
    }

    func addPredefinedStops() {
        for location in predefinedLocations {
            let point = Point(x: location.y, y: location.x, spatialReference: .wgs84)
            addStop(at: point)
        }
    }

    func addStop(at point: Point) {
        guard selectedStops.count < 5 else {
            errorMessage = "You can only add up to 5 stops."
            return
        }
        let stop = Stop(point: point)
        selectedStops.append(stop)
        let stopGraphic = makeStopGraphic(at: point)
        routeGraphicsOverlay.addGraphic(stopGraphic)
        Task {
            let address = await reverseGeocode(point: point)
            DispatchQueue.main.async {
                self.routeDetails += "Point \(self.selectedStops.count): \(address)\n"
            }
        }
        errorMessage = nil
    }

    private func makeStopGraphic(at point: Point) -> Graphic {
        guard let pinImage = UIImage(named: "ToruisIcon2") else {
            fatalError("pinImage not found")
        }
        let symbol = PictureMarkerSymbol(image: pinImage)
        return Graphic(geometry: point, symbol: symbol)
    }

    func solveRoute() async {
        do {
            guard selectedStops.count >= 2 else {
                errorMessage = "Please select at least 2 points."
                return
            }
            let parameters = try await routeTask.makeDefaultParameters()
            parameters.setStops(selectedStops)
            parameters.returnsDirections = true
            parameters.directionsLanguage = "en"
            
            let routeResult = try await routeTask.solveRoute(using: parameters)
            guard let solvedRoute = routeResult.routes.first else { return }
            routeGraphic.geometry = solvedRoute.geometry
            DispatchQueue.main.async {
                self.routeGraphicsOverlay.addGraphic(self.routeGraphic)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to calculate the route: \(error.localizedDescription)"
            }
        }
    }

    func reverseGeocode(point: Point) async -> String {
        do {
            let result = try await geocoder.reverseGeocode(forLocation: point).first
            if let address = result?.attributes["Match_addr"] as? String {
                return address
            } else {
                return "Unknown Location"
            }
        } catch {
            return "Unknown Location"
        }
    }
}

struct MyTripMap: View {
    @StateObject private var model1 = Model1()

    var body: some View {
        VStack(spacing: 0) {
            MapView(map: model1.map, graphicsOverlays: [model1.routeGraphicsOverlay])
                .edgesIgnoringSafeArea(.all)
                .frame(maxHeight: .infinity)
            
            List(predefinedLocations, id: \.name) { location in
                VStack(alignment: .leading) {
                    Text(location.name)
                        .font(.headline)
                    Text(location.description)
                        .font(.subheadline)
                }
                .padding()
            }

            VStack {
                if let errorMessage = model1.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                }

                if model1.selectedStops.count >= 2 {
                    Button("Calculate Route") {
                        Task {
                            await model1.solveRoute()
                        }
                    }
                    .padding()
                    .background(Color(red: 45.0/255, green: 154.0/255, blue: 161.0/255))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.bottom, 20)
            .background(Color.white)
        }
    }
}
