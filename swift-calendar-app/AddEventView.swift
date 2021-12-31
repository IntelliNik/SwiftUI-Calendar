//
//  AddEventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 24.12.21.
//

import SwiftUI
import MapKit

struct AddEventView: View {
    
    @State private var name: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var locationSearch = ""

    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView{
            ScrollView {
                TextField("Name", text: $name).padding()
                
                DatePicker(selection: $startDate, in: ...Date(), displayedComponents: .date) {
                    Text("Start date")
                }.padding()
                
                DatePicker(selection: $endDate, in: ...Date(), displayedComponents: .date) {
                    Text("End date")
                }.padding()
                
                TextField("Location search", text: $locationSearch).padding()
                
                Map(coordinateRegion: $region)
                    .frame(width: 400, height: 300)
                    .navigationTitle("Add event")
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button("Discard"){
                                dismiss()
                            }.foregroundColor(.gray)
                        }
                        ToolbarItem(placement: .primaryAction) {
                            Button("Save"){
                                dismiss()
                            }.foregroundColor(Color(getAccentColor()))
                        }
                    }

            }
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
