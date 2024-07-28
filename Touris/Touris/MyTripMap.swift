import SwiftUI
import ArcGIS

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
        self.map.initialViewpoint = Viewpoint(latitude: 45.526201, longitude: -122.65, scale: 144447.638572)
        let symbol = SimpleLineSymbol(style: .solid, color: .systemBlue, width: 4)
        self.routeGraphic = Graphic(geometry: nil, symbol: symbol)
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
            parameters.directionsLanguage = "es"
            
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
                .onSingleTapGesture { screenPoint, mapPoint in
                    model1.addStop(at: mapPoint)
                }
                .edgesIgnoringSafeArea(.all)
                .frame(maxHeight: .infinity)

            if !model1.routeDetails.isEmpty {
                VStack {
                    ScrollView {
                        Text(model1.routeDetails)
                            .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .frame(height: 200)
                }
                .transition(.move(edge: .bottom))
                .animation(.default)
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
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.bottom, 20)
            .background(Color.white)
        }
    }
}
