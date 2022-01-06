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
    let urlPrefixes = ["http://", "https://"]
    @State private var urlPrefix: String = "https://"
    
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
    let repetitionIntevals = ["Daily", "Weekly", "Monthly", "Yearly"]
    @State private var repetitionInterval = "Daily"
    let repeatUntilModes = ["Forever", "Repetitions", "End Date"]
    @State private var repeatUntil = "Forever"
    @State private var amountOfRepetitions = "10"
    
    @State private var notification = true
    @State private var notificationMinutesBefore = 5
    @State private var notficationTimeAtWholeDay = getDateFromHours(hours: "08:00")!
    
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
                        ForEach((0..<calendars.count), id: \.self) { index in
                            HStack{
                                Image(systemName: "square.fill")
                                    .foregroundColor( getColorFromString(stringColor: calendars[index].color ?? "Yellow") )
                                    .imageScale(.large)
                                Text("\(calendars[index].name!)")
                            }.tag(index)
                        }
                    }.padding()
                }
                Section{
                    TextField("Name", text: $name).padding()
                }
                Section{
                    Toggle("Whole Day", isOn: $wholeDay)
                        .onChange(of: wholeDay) { value in
                            if(value){
                                datePickerComponents = [.date]
                                // set notification default to one day before
                                notificationMinutesBefore = 24*60
                            } else {
                                datePickerComponents = [.date, .hourAndMinute]
                                // set notification default to 5 minutes before
                                notificationMinutesBefore = 5
                            }
                        }
                        .padding()
                    DatePicker(selection: $startDate, displayedComponents: datePickerComponents) {
                        Text("Start")
                    }.padding()
                    DatePicker(selection: $endDate, in: startDate..., displayedComponents: datePickerComponents) {
                        Text("End")
                    }.padding()
                }
                Section{
                    Toggle("Notification", isOn: $notification).padding()
                    if(notification){
                        Picker("When", selection: $notificationMinutesBefore) {
                            if(!wholeDay){
                                Text("On Time").tag(0)
                                Text("5min before").tag(5)
                                Text("15min before").tag(15)
                                Text("30min before").tag(30)
                                Text("1 hour before").tag(60)
                                Text("1 day before").tag(24*60)
                            } else {
                                Text("1 day before").tag(24*60)
                                Text("2 days before").tag(2*24*60)
                                Text("1 week before").tag(7*24*60)
                            }
                        }.padding()
                        if(wholeDay){
                            DatePicker(selection: $notficationTimeAtWholeDay, displayedComponents: [.hourAndMinute]) {
                                Text("At time")
                            }.padding()
                        }
                    }
                }
                Section{
                    Toggle("Repeat", isOn: $repetition).padding()
                    if(repetition){
                        Picker("Interval", selection: $repetitionInterval) {
                            ForEach(repetitionIntevals, id: \.self) {
                                Text($0)
                            }
                        }.padding()
                        Picker("Until", selection: $repeatUntil) {
                            ForEach(repeatUntilModes, id: \.self) {
                                Text($0)
                            }
                        }.padding()
                        if(repeatUntil == "Repetitions"){
                            HStack{
                                Text("Repetitions").padding()
                                Spacer()
                                TextField("Repetitions", text: $amountOfRepetitions)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .padding()
                            }
                        }
                        if(repeatUntil == "End Date"){
                            DatePicker(selection: $endRepetitionDate, in: endDate..., displayedComponents: [.date]){
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
                            Image(systemName: "magnifyingglass").padding()
                            Spacer()
                            TextField("Search for location ...", text: $locationSearch)
                                .autocapitalization(.none)
                                .padding()
                        }
                        Map(coordinateRegion: $customRegion)
                            .frame(minHeight: 200)
                    }
                }
                Section{
                    HStack{
                        Picker("", selection: $urlPrefix){
                            ForEach(urlPrefixes, id: \.self) {
                                Text($0).tag($0)
                                    .font(.system(size: 16))
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 25)
                        .clipped()
                        .padding([.trailing, .top, .bottom])
                        TextField("URL", text: $urlString)
                            .autocapitalization(.none)
                    }
                    TextField("Notes", text: $notes)
                        .autocapitalization(.none)
                        .padding()
                }
            }
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
                        event.key = UUID()
                        if name != ""{
                            event.name = name
                        }
                        event.startdate = startDate
                        event.enddate = endDate
                        event.wholeDay = wholeDay
                        // make sure the protocol is set, such that the link works also without entering http:// or https:// at the beginning
                        if(urlString != ""){
                            event.urlPrefix = urlPrefix
                            event.url = urlString
                        }
                        if(notes != ""){
                            event.notes = notes
                        }
                        
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
                            // TODO: save the name of the location somehow in event.locationName
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
                            event.repetitionUntil = repeatUntil
                            event.repetitionInterval = repetitionInterval
                            if(repeatUntil == "Repetitions"){
                                event.repetitionAmount = Int16(amountOfRepetitions) ?? 10
                            }
                            if(repeatUntil == "End Date"){
                                event.repetitionEndDate = endRepetitionDate
                            }
                            event.repetitionSkip = false
                            // TODO: Calculate the next date for the repetation and generate a event in Core Data. Store here the id of the next event in the next line
                            event.repetitionNext = "Test"
                        } else {
                            event.repetition = false
                            
                            //TODO: Check whether it breaks something to have items as nil
                            // event.nextRepetition = ""
                        }

                        if notification {
                            event.notification = true
                            if(!wholeDay){
                                event.notificationMinutesBefore = Int32(notificationMinutesBefore)
                            } else {
                                event.notificationTimeAtWholeDay = notficationTimeAtWholeDay
                            }

                        }
                        calendars[calendar].addToEvents(event)
                        
                        try? moc.save()
                        
                        dismiss()
                    }.foregroundColor(Color(getAccentColorString()))
                    .navigationTitle("Add event")
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
            }
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView(saveEvent: .constant(true))
    }
}
