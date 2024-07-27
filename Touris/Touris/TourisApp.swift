//
//  TourisApp.swift
//  Touris
//
//  Created by Arushi Goyal on 7/26/24.
//

import SwiftUI
import ArcGIS
import ArcGISToolkit

@main
struct TourisApp: App {
    
    init() {
        ArcGISEnvironment.apiKey = APIKey("AAPKfef7d1470143483bb582cd743db8bd98zPxkBR_WSA-MNtN1QDcuUQBYnk8qiLfSwNCh4ZPY_Ex87-DyXOVDDDeumrLYTQMl")
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
        }
    }
}
