//
//  MyTripMap.swift
//  Touris
//
//  Created by Shashwot Niraula on 7/27/24.
//
import Foundation
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
            await updateRouteDetails(with: solvedRoute)
            DispatchQueue.main.async {
                self.routeGraphicsOverlay.addGraphic(self.routeGraphic)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to calculate the route: \(error.localizedDescription)"
            }
        }
    }

    private func updateRouteDetails(with route: Route) async {
        let startTime = Date()
        let travelTime = route.totalTime
        let travelDistance = route.totalLength
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedStartTime = dateFormatter.string(from: startTime)
        let destinationTime = Calendar.current.date(byAdding: .minute, value: Int(travelTime), to: startTime) ?? Date()
        let formattedDestinationTime = dateFormatter.string(from: destinationTime)
        let addresses = await reverseGeocode(stops: selectedStops)
        let pinnedPoints = addresses.enumerated().map { index, address in
            "Point \(index + 1): \(address)"
        }.joined(separator: "\n")
        routeDetails = """
            Start Time: \(formattedStartTime)
            Travel Time: \(travelTime) minutes
            Travel Distance: \(travelDistance) meters
            Destination Time: \(formattedDestinationTime)
            
            Pinned Points in Order:
            \(pinnedPoints)
            """
    }

    func reverseGeocode(stops: [Stop]) async -> [String] {
        var addresses: [String] = []
        for stop in stops {
            do {
                let result = try await geocoder.reverseGeocode(forLocation: stop.geometry as! Point).first
                if let address = result?.attributes["Match_addr"] as? String {
                    addresses.append(address)
                } else {
                    addresses.append("Unknown Location")
                }
            } catch {
                addresses.append("Unknown Location")
            }
        }
        return addresses
    }
}

struct MyTripMap: View {
    @StateObject private var model1 = Model1()

    var body: some View {
        VStack {
            MapView(map: model1.map, graphicsOverlays: [model1.routeGraphicsOverlay])
                .onSingleTapGesture { screenPoint, mapPoint in
                    model1.addStop(at: mapPoint)
                }
            if let errorMessage = model1.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            ScrollView {
                Text(model1.routeDetails)
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
            Button("Save Route Details") {
                model1.saveRouteDetails()
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}



extension Model1 {
    func saveRouteDetails() {
        let fileName = getDocumentsDirectory().appendingPathComponent("routeDetails.txt")
        do {
            try routeDetails.write(to: fileName, atomically: true, encoding: .utf8)
            print("Route details saved.")
        } catch {
            print("Failed to save route details: \(error.localizedDescription)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
