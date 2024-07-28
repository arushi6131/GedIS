//
//  HeaderView.swift
//  Touris
//
//  Created by Arushi Goyal on 7/26/24.
//

import Foundation
import SwiftUI

struct HeaderView: View {
    @State private var isProfileViewPresented = false
    @State private var profileImage: UIImage? = UIImage(named: "profile_picture") // Add your image name here

    var body: some View {
        HStack {
            Text("TOURIS")
                .font(.custom("Lovelo", size: 34))
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.black)
            Spacer() // Push the profile button to the right
            Button(action: {
                isProfileViewPresented.toggle()
            }) {
                if let profileImage = profileImage {
                    Image("Arno")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40) // Set the size of the profile picture
                        .clipShape(Circle()) // Make the image circular
                        .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Optional border
                        .shadow(radius: 2) // Optional shadow
                } else {
                    Image(systemName: "person.crop.circle")
                        .font(.title)
                        .padding()
                }
            }
        }
        .background(Color.white) // Set a background color for the header
        .shadow(radius: 2) // Add a shadow for a slight elevation effect
        .sheet(isPresented: $isProfileViewPresented) {
            PProfileView()
        }
    }
}

