import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date? // Binding to the selected date
    @Environment(\.dismiss) var dismiss // Environment variable to dismiss the view

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date and Time", selection: Binding<Date>(
                    get: { selectedDate ?? Date() }, // Provide a default date if nil
                    set: { selectedDate = $0 } // Update the selected date
                ), in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(GraphicalDatePickerStyle()) // Use graphical style for date picker
                .padding()

                Button("Confirm") {
                    dismiss() // Dismiss the view when the button is tapped
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// TestLocation struct representing a location
struct TestLocation: Identifiable {
    var id = UUID() // Unique identifier
    var name: String
    var selectedDate: Date? // Store the selected date and time
}

struct MyTripView: View {
    @State private var isTripMap = false
    // Hardcoded locations as a mutable State variable
    @State private var locations: [TestLocation] = [
        TestLocation(name: "Rodeo Drive", selectedDate: nil),
        TestLocation(name: "Universal Studios", selectedDate: nil),
        TestLocation(name: "Santa Monica Pier", selectedDate: nil),
    ]
    
    @State private var showingCalendar: Bool = false // Track if calendar view should be shown
    @State private var selectedLocation: TestLocation? // Track the selected location for date setting
    @Binding var exploreVariable: String
    @Binding var addToTripLocations: [Location]

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($locations) { $location in // Use binding to modify the location directly
                        HStack {
                            VStack(alignment: .leading) {
                                Text(location.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 2)
                                
                                // Display the selected date if available
                                if let selectedDate = location.selectedDate {
                                    Text("Date: \(formattedDate(selectedDate))")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                } else {
                                    Text("No date selected")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            // Button to open calendar
                            Button(action: {
                                withAnimation { // Add animation for the button
                                    selectedLocation = location // Set the selected location
                                    showingCalendar.toggle() // Show the calendar view
                                }
                            }) {
                                Image(systemName: "calendar") // Use a calendar icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30) // Smaller button size
                                    .padding(10)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle()) // Make it circular
                                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.vertical, 5) // Spacing between rows
                    }
                    .onDelete(perform: deleteLocation) // Enable swipe-to-delete
                }
                .toolbar {
                    // Navigation link to ExploreView
                    NavigationLink(destination: ExploreView(addToTripLocations: addToTripLocations)) {
                        Text("Explore Locations")
                    }
                    Spacer()
                    EditButton() // Add Edit button to toggle delete mode
                }
                .listStyle(PlainListStyle()) // Remove default list styling for better appearance

                // Add the "View My Trip Map" button
                Button(action: {
                    isTripMap.toggle()
                    // Action for viewing the trip map
                }) {
                    Text("View My Trip Map")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20) // Space at the bottom of the view
                .sheet(isPresented: $isTripMap) {
                    MyTripMap()
                }
            }
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)) // Background color
            .sheet(isPresented: $showingCalendar) {
                if let location = selectedLocation {
                    CalendarView(selectedDate: $locations[locations.firstIndex(where: { $0.id == location.id })!].selectedDate) // Pass the binding of the selected date
                }
            }
        }
    }

    // Function to delete a location
    private func deleteLocation(at offsets: IndexSet) {
        locations.remove(atOffsets: offsets)
    }

    // Function to format the date for display
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
