//
//  AddEventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 24.12.21.
//

import SwiftUI
import MapKit

struct AddEventView: View {
    
    @State var datePickerComponents: DatePickerComponents = [.date, .hourAndMinute]
    
    @State private var name: String = ""
    @State private var urlString: String = "http://apple.com"
    //@State private var metadataView: MetadataView?
    
    @State private var notes: String = ""
    
    
    @State private var calendar = 0
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var endRepetitionDate = Date()
    
    @State private var location: String = "None"
    @State private var locationSearch = ""
    let locationModes = ["None", "Current", "Custom"]
    
    @State private var wholeDay = false
    
    @State private var repetition = false
    let repetionModes = ["Daily", "Weekly", "Monthly", "Yearly"]
    @State private var repetitionMode = "Daily"
    let repeatUntilModes = ["Forever", "Amount of repetitions", "End Date"]
    @State private var repeatUntil = "Forever"
    @State private var amountOfRepetitions = "10"
    
    @State private var currentRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @State private var customRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @State var confirmationShown = false
    
    @Binding var save: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    Picker("Calendar", selection: $calendar) {
                        HStack{                            
                            Image(systemName: "square.fill")
                                .foregroundColor(.yellow)
                                .imageScale(.large)
                            Text("Calendar x")
                        }.tag(0)
                        HStack{
                            Image(systemName: "square.fill")
                                .foregroundColor(.green)
                                .imageScale(.large)
                            Text("Calendar y")
                        }.tag(1)
                        HStack{
                            Image(systemName: "square.fill")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            Text("Calendar z")
                        }.tag(2)
                    }.padding()
                }
                Section{
                    TextField("Name", text: $name).padding()
                        .navigationTitle("Add event")
                        .toolbar {
                            ToolbarItem(placement: .navigation) {
                                Button("Discard"){
                                    confirmationShown = true
                                }
                                .foregroundColor(.gray)
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button("Save event"){
                                    save = true

                                    let event = Event(context: moc)
                                    event.name = "Test Event"
                                    event.startdate = startDate
                                    event.enddate = endDate
                                    
                                    try? moc.save()

                                    dismiss()
                                }.foregroundColor(Color(getAccentColor()))
                            }
                        }
                        .confirmationDialog(
                            "Are you sure?",
                             isPresented: $confirmationShown
                        ) {
                            Button("Discard event"){
                                save = false
                                dismiss()
                            }
                        }
                }
                Section{
                    Toggle("Whole Day", isOn: $wholeDay)
                        .onChange(of: wholeDay) { value in
                            if(value){
                                datePickerComponents = [.date]
                                
                            } else {
                                datePickerComponents = [.date, .hourAndMinute]
                            }
                        }
                        .padding()
                    DatePicker(selection: $startDate, in: ...Date(), displayedComponents: datePickerComponents) {
                        Text("Start")
                    }.padding()
                    DatePicker(selection: $endDate, in: ...Date(), displayedComponents: datePickerComponents) {
                        Text("End")
                    }.padding()
                }
                Section{
                    Toggle("Repeat", isOn: $repetition).padding()
                    if(repetition){
                        Picker("Until", selection: $repeatUntil) {
                            ForEach(repeatUntilModes, id: \.self) {
                                Text($0)
                            }
                        }.padding()
                        if(repeatUntil == "Amount of repetitions"){
                            HStack(){
                                Text("Amount of repetitions").padding()
                                Spacer()
                                TextField("", text: $amountOfRepetitions)
                                    .keyboardType(.numberPad)
                            }
                        }
                        if(repeatUntil == "End Date"){
                            DatePicker(selection: $endRepetitionDate, in: ...Date(), displayedComponents: [.date]){
                                Text("End Date")
                            }
                            .padding()
                        }
                    }
                }
                Section{
                    HStack{
                        Text("Location")
                            .padding()
                        Picker("Location", selection: $location) {
                            ForEach(locationModes, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                    }
                    if(location == "Current"){
                        Map(coordinateRegion: $currentRegion, showsUserLocation: true, userTrackingMode: .constant(.follow))
                            .frame(minHeight: 200)
                    }
                    if(location == "Custom"){
                        HStack{
                            TextField("Search for location ...", text: $locationSearch)
                                .padding()
                            Image(systemName: "magnifyingglass")
                        }
                        Map(coordinateRegion: $customRegion)
                            .frame(minHeight: 200)
                    }
                }
                Section{
                    TextField("URL", text: $urlString)
                        .padding()
                        .onChange(of: urlString){ url in
                            //metadataView = MetadataView(vm: LinkViewModel(link: url))
                        }
                    TextField("Notes", text: $notes).padding()
                }
            }
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView(save: .constant(true))
    }
}
