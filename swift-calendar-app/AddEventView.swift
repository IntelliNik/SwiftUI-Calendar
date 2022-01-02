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
    @State private var urlString: String = ""
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
    
    @Binding var saveEvent: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ]
    ) var calendars: FetchedResults<MCalendar>
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    Picker("Calendar", selection: $calendar) {
                        /*HStack{
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
                        }.tag(2)*/
                        ForEach((0..<calendars.count)) { index in
                            HStack{
                                //TODO: Find another way to transform string to color
                                Image(systemName: "square.fill")
                                    .foregroundColor( getColor(stringColor: calendars[index].color ?? "Yellow") )
                                    .imageScale(.large)
                                Text("\(calendars[index].name ?? "Anonymous")")
                            }.tag(index)
                        }
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
                                    saveEvent = true

                                    let event = Event(context: moc)
                                    //TODO: Is the function UUID doing what we want?
                                    event.key = UUID()
                                    // TODO: event.key = generateID(startDate: startDate, endDate: endDate, name: name)
                                    event.name = name
                                    event.startdate = startDate
                                    event.enddate = endDate
                                    event.wholeDay = wholeDay
                                    event.url = urlString
                                    event.notes = notes
                                    
                                    // TODO: Good way to save a location?
                                    if (location == "Current"){
                                        event.location = true
                                        event.latitude = currentRegion.center.latitude
                                        event.longitude = currentRegion.center.latitude
                                        event.latitudeDelta = currentRegion.span.latitudeDelta
                                        event.longitudeDelta = currentRegion.span.longitudeDelta
                                    } else if (location == "Custom")
                                               {
                                        event.location = true
                                        event.latitude = customRegion.center.latitude
                                        event.longitude = customRegion.center.latitude
                                        event.latitudeDelta = customRegion.span.latitudeDelta
                                        event.longitudeDelta = customRegion.span.longitudeDelta
                                    } else {
                                        event.location = false
                                        //TODO: Check whether it breaks something to have items as nil
                                        //event.latitude = 0.0
                                        //event.longitude = 0.0
                                        //event.latitudeDelta = 0.0
                                        //event.longitudeDelta = 0.0
                                    }
                                    
                                    if repetition {
                                        event.repetition = true
                                        event.skip = false
                                        // TODO: Calculate the next date for the repetation and generate a event in Core Data. Store here the id of the next event in the next line
                                        event.nextRepetition = "Test"
                                    } else {
                                        event.repetition = false
                                        //TODO: Check whether it breaks something to have items as nil
                                        // event.nextRepetition = ""
                                    }
                                    
                                    //TODO: Search for the correct calendar in the core data base and add the event there
                                    //calendarAddEvent(name: ("Calendar" + String(calendar)), event: event)
                                    calendarAddEvent(name: "Calendar1", event: event)
                                    
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
                                saveEvent = false
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
    
    func generateID (startDate: Date, endDate: Date, name: String) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        let randomInt = Int.random(in: 1..<100000)
        
        return name + formatter.string(from: startDate) + formatter.string(from: endDate) + String(randomInt)
    }
    
    func calendarAddEvent(name: String, event: Event ){
        if calendars.isEmpty{
            //TODO: Tell the user that no calendar exists
        } else {
            for calendar in calendars{
                if (calendar.name == name){
                    calendar.addToEvents(event)
                    break
                }
            }
            //TODO: if no calendar of name can be found inform the user
        }
    }
    
    //TODO: Find another way to transform string to color
    func getColor(stringColor: String) -> Color{
        switch stringColor{
            case "Yellow": return .yellow
            case ".green": return .green
            default: return .yellow
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView(saveEvent: .constant(true))
    }
}
