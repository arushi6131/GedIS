import SwiftUI
import ArcGIS

struct CardDetailView: View {
    var itinerary: Itinerary

    @State private var isExpanded: Bool = false

    @StateObject private var model = Model()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map view with points added
            MapViewContainer(itinerary: itinerary, model: model)

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
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(location.photos, id: \.self) { photoName in
                                                if let image = UIImage(named: photoName) {
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
                                    model.zoomTo(location: location)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 20)
                .frame(maxHeight: isExpanded ? .infinity : 300)
                .frame(maxWidth: .infinity)  // Ensure it covers the entire width
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
    @ObservedObject var model: Model

    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: model.map, graphicsOverlays: [model.graphicsOverlay])
                .onAppear {
                    model.mapViewProxy = mapViewProxy
                    addPointsToMap()
                }
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

public class Model: ObservableObject {
    let map: Map
    let graphicsOverlay = GraphicsOverlay()
    @Published var mapViewProxy: MapViewProxy?

    init() {
        let url = URL(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=0dd3259879ab43e79a9f878e2febf1a2")!
        self.map = Map(url: url)!
    }

    func makeStopGraphic(at point: Point) -> Graphic {
        // Load the custom image from assets
        guard let customImage = UIImage(named: "ToruisIcon2") else {
            fatalError("Image not found in assets")
        }
        
        // Create a PictureMarkerSymbol with the custom image
        let pictureSymbol = PictureMarkerSymbol(image: customImage)
        pictureSymbol.width = 24
        pictureSymbol.height = 24
        pictureSymbol.offsetY = 12  // Adjust offset if needed

        // Create and return the graphic with the custom symbol
        return Graphic(geometry: point, symbol: pictureSymbol)
    }

    func zoomTo(location: Location) {
        guard let mapViewProxy = mapViewProxy else { return }
        let point = Point(x: location.x, y: location.y, spatialReference: .wgs84)
        let viewpoint = Viewpoint(center: point, scale: 10000)
        Task {
            await mapViewProxy.setViewpoint(viewpoint)
        }
    }
}




