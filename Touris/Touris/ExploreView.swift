import SwiftUI
import ArcGIS
import ArcGISToolkit

struct ExploreView: View {
    /// The viewpoint used by the search view to pan/zoom the map to the extent
    /// of the search results.
    @State private var viewpoint: Viewpoint? = Viewpoint(
        center: Point(
            x: -118.2426,
            y: 34.0549,
            spatialReference: .wgs84
        ),
        scale: 1e6
    )

    /// Denotes whether the map view is navigating. Used for the repeat search
    /// behavior.
    @State private var isGeoViewNavigating = false

    /// The current map view extent. Used to allow repeat searches after
    /// panning/zooming the map.
    @State private var geoViewExtent: Envelope?

    /// The center for the search.
    @State private var queryCenter: Point?

    /// The screen point to perform an identify operation.
    @State private var identifyScreenPoint: CGPoint?

    /// The tap location to perform an identify operation.
    @State private var identifyTapLocation: Point?

    /// The placement for a graphic callout.
    @State private var calloutPlacement: CalloutPlacement?

    /// Provides search behavior customization.
    @ObservedObject private var locatorDataSource = LocatorSearchSource(
        name: "My Locator",
        maximumResults: 10,
        maximumSuggestions: 5
    )

    /// The view model for the sample.
    @StateObject private var model = Model()
    
    /// Variables to store x and y coordinates.
    @State private var xCoordinate: Double = 0.0
    @State private var yCoordinate: Double = 0.0

    var body: some View {
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
            .onNavigatingChanged { isGeoViewNavigating = $0 }
            .onViewpointChanged(kind: .centerAndScale) {
                queryCenter = $0.targetGeometry.extent.center
            }
            .onVisibleAreaChanged { newVisibleArea in
                // For "Repeat Search Here" behavior, use `geoViewExtent` and
                // `isGeoViewNavigating` modifiers on the search view.
                geoViewExtent = newVisibleArea.extent
            }
            .callout(placement: $calloutPlacement.animation()) { placement in
                VStack {
                    if let attributes = placement.geoElement?.attributes {
                        Text("\(attributes["PlaceName"] ?? "N/A")")
                        Text("Address: \(attributes["Place_addr"] ?? "N/A")")
                        // Text("Type: \(attributes["Type"] ?? "N/A")")

                    } else {
                        Text("Unknown Address")
                            .padding()
                    }
                }
                .padding()
            }
            .task(id: identifyScreenPoint) {
                guard let screenPoint = identifyScreenPoint,
                      // Identifies when user taps a graphic.
                      let identifyResult = try? await proxy.identify(
                        on: model.searchResultsOverlay,
                        screenPoint: screenPoint,
                        tolerance: 10
                      )
                else {
                    return
                }
                // Creates a callout placement at the user tapped location.
                calloutPlacement = identifyResult.graphics.first.flatMap { graphic in
                    // Extract coordinates and update the variables.
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
                        // Hides the callout when query is cleared.
                        calloutPlacement = nil
                    }
                }
                .padding()
            }
        }
    }
}

private extension ExploreView {
    class Model: ObservableObject {
        /// A map initialized from a URL.
        let map: Map

        /// The graphics overlay used by the search toolkit component to display
        /// search results on the map.
        let searchResultsOverlay = GraphicsOverlay()

        init() {
            // Initialize the map with the URL of the map service or web map
            let url = URL(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=0dd3259879ab43e79a9f878e2febf1a2")!
            self.map = Map(url: url)!
        }
    }
}
