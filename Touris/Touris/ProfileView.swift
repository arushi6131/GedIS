import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                
                Button(action: {
                    // Action for the edit profile button
                    print("Edit Profile tapped")
                }) {
                    Text("Edit Profile")
                        .font(.body)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.trailing, 20)
                }
            }
            .padding(.top, 20)
            
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.leading, 20)
                
                VStack(alignment: .leading) {
                    Text("Arno Abrahamian")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("aabrahamian@esri.com")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.top, 20)
            
            HStack {
                VStack {
                    Text("Trips")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("5")
                        .font(.headline)
                }
                
                Spacer()
                
                VStack {
                    Text("Followers")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("5")
                        .font(.headline)
                }
                
                Spacer()
                
                VStack {
                    Text("Following")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("5")
                        .font(.headline)
                }
            }
            .padding(.horizontal, 20)
            
            Text("Bio")
                .font(.headline)
                .padding(.horizontal, 20)
            
            Text("USC Alumni | Los Angeles")
                .font(.body)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
    }
}

