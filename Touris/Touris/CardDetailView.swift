import SwiftUI
import ArcGIS

struct CardDetailView: View {
    var itinerary: Itinerary

    @State private var isExpanded: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map view with points added
            MapViewContainer(itinerary: itinerary)

            // Pull-up menu
            VStack(spacing: 0) {
                Capsule()
                    .frame(width: 40, height: 6)
                    .padding(.top)
                    .padding(.bottom, 8)

                VStack {
                    Text(itinerary.name)
                        .font(.headline)
                        .padding()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(itinerary.locations) { location in
                                VStack(alignment: .leading) {
                                    Text(location.name)
                                        .font(.headline)
                                    Text(location.description)
                                        .font(.subheadline)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .padding(.vertical, 5)
                            }
                        }
                        .padding()
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 20)
                .frame(maxHeight: isExpanded ? .infinity : 300)
                .animation(.spring())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height < 0 {
                                isExpanded = true
                            } else {
                                isExpanded = false
                            }
                        }
                )
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MapViewContainer: View {
    var itinerary: Itinerary

    @StateObject private var model = Model()

    var body: some View {
        MapView(
            map: model.map,
            graphicsOverlays: [model.graphicsOverlay]
        )
        .onAppear {
            addPointsToMap()
        }
    }

    private func addPointsToMap() {
        for location in itinerary.locations {
            let point = Point(x: location.x, y: location.y, spatialReference: .wgs84)
            let graphic = model.makeStopGraphic(at: point)
            model.graphicsOverlay.addGraphic(graphic)
        }
    }
}

private extension MapViewContainer {
    class Model: ObservableObject {
        let map: Map
        let graphicsOverlay = GraphicsOverlay()

        init() {
            let url = URL(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=0dd3259879ab43e79a9f878e2febf1a2")!
            self.map = Map(url: url)!
        }

        func makeStopGraphic(at point: Point) -> Graphic {
            let symbol = SimpleMarkerSymbol(style: .circle, color: .white, size: 12)
            symbol.outline = SimpleLineSymbol(style: .solid, color: .black, width: 2)
            return Graphic(geometry: point, symbol: symbol)
        }
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(itinerary: Itinerary(id: 1, name: "Sample Itinerary", description: "Sample description", locations: [Location(name: "Sample Location", description: "Sample description", photos: ["sample_photo"], x: -118.352918, y: 34.137743)]))
    }
}

