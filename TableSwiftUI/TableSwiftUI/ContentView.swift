//
//  ContentView.swift
//  TableSwiftUI
//
//  Created by Henriquez Perez, Natalia on 3/31/25.
//

import SwiftUI
import MapKit

let data = [
    Item(name: "Barefoot Campus Outfitter", address: "300 N LBJ Dr", desc: "The perfect boutique to shop for campus and gameday outfits.", lat: 29.884793321648676, long: -97.94026864952323, imageName: "co", category: "Campus"),
    Item(name: "KnD's Boutique", address: " 312 N LBJ Dr", desc: "This shop offers a variety of items from trendy clothing to stylish accessories.", lat: 29.88490711255401, long: -97.94028852253646, imageName: "KnD", category: "Trendy"),
    Item(name: "Pitaya", address: "230 N LBJ Dr", desc: "The perfect boutique to keep up to date with the most modern and trendy styles.", lat: 29.884162418308634, long: -97.93987817281246, imageName: "pit", category: "Trendy"),
    Item(name: "Vagabond", address: "320 N LBJ Dr", desc: "This shop offers a variety of vintage clothing items, and is ideal for people who are into sustainable fashion.", lat: 29.885118312218932, long: -97.94018037466118, imageName: "vag", category: "Vintage"),
    Item(name: "Daughter of the Wild", address: "218 N Guadalupe St", desc: "If you're into spirituality and hand-made items, then this is the shop for you.", lat: 29.88367699588592, long: -97.9413215881546, imageName: "DOW", category: "Spirituality")
]

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let desc: String
    let lat: Double
    let long: Double
    let imageName: String
    let category: String // Category field
}

struct ContentView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 29.884793321648676, longitude: -97.94026864952323), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
    @State private var selectedCategory: String = "All" // Default to show all items
    @State private var filteredData = data // Initially, all items are shown

    var categories: [String] {
        ["All"] + Array(Set(data.map { $0.category })).sorted() // Get unique categories, including "All"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Add the Picker to select the category for filtering
                Picker("Select Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Make it appear as a menu
                .padding()
                .onChange(of: selectedCategory) { newValue in
                    filterData(by: newValue)
                }

                // List content with proper padding to avoid cutoff
                List(filteredData, id: \.name) { item in
                    NavigationLink(destination: DetailView(item: item)) {
                        HStack {
                            Image(item.imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.address)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding(.top, 10) // Add padding to the list to avoid cutoff at the top
                .listStyle(PlainListStyle())
                .frame(maxHeight: .infinity) // Ensures the list takes up all available space
                .navigationTitle("San Marcos Boutiques")
                
                // Add the Map below the List
                Map(coordinateRegion: $region, annotationItems: filteredData) { item in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long)) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                            .overlay(
                                Text(item.name)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .offset(y: 25)
                            )
                    }
                }
                .frame(height: 300) // You can adjust this height as needed
                .padding(.bottom, 0) // Ensure map has no extra padding at the bottom
            }
        }
    }
    
    // Function to filter data based on selected category
    func filterData(by category: String) {
        if category == "All" {
            filteredData = data
        } else {
            filteredData = data.filter { $0.category == category }
        }
    }
}

struct DetailView: View {
    @State private var region: MKCoordinateRegion
    
    init(item: Item) {
        self.item = item
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }
    
    let item: Item
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Image and description at the top
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 500)
                
                Text("Address: \(item.address)")
                    .font(.subheadline)
                    .padding(.top, 5)
                
                Text("Description: \(item.desc)")
                    .font(.subheadline)
                    .padding(.top, 10)
                    .padding(.horizontal, 10) // Adding consistent horizontal padding
                
                Text("Category: \(item.category)")
                    .font(.subheadline)
                    .padding(.top, 5)
                    .padding(.horizontal, 10) // Align the category text with description
                
                Spacer() // This ensures the content above the map is pushed up
                
                // Map at the bottom
                Map(coordinateRegion: $region, annotationItems: [item]) { item in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.lat, longitude: item.long)) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                            .overlay(
                                Text(item.name)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .offset(y: 25)
                            )
                    }
                }
                .frame(height: geometry.size.height / 3) // Map will take up 1/3 of the screen height
                .padding(.bottom, 0) // No extra padding at the bottom
            }
            .frame(height: geometry.size.height) // Ensures the entire screen height is used
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .font(.system(size: 26, weight: .bold)) // Make the title larger
    }
}

#Preview {
    ContentView()
}
