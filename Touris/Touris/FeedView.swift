//
//  FeedView.swift
//  Touris
//
//  Created by Arushi Goyal on 7/26/24.
//

import Foundation
import SwiftUI

struct CardView: View {
    var title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
}

struct FeedView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(1..<21) { index in
                    CardView(title: "Card \(index)")
                }
            }
            .padding()
        }
        .background(Color.red)
        .edgesIgnoringSafeArea(.all)
    }
}
