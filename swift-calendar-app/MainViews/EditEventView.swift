//
//  EditEventView.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 11.01.22.
//

import SwiftUI
import MapKit
import WidgetKit

// Edit view for events

struct EditEventView: View {
    
    @State var datePickerComponents: DatePickerComponents = [.date, .hourAndMinute]
    
    // Event which shold be modified
    @State var event: Event
    @State var confirmationShown = false
    @State private var name: String = ""
    
    @State private var urlString: String = ""
    let urlPrefixes = ["http://", "https://"]
    
    @State private var notes: String = ""
    
    @State private var calendar = 0
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var endRepetitionDate = Date()
    
    @State private var location: String = "None"
    @State private var locationBool: Bool = false
    @State private var locationSearch = ""
    @State private var markers = [Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), tint: .red))]
    let locationModes = ["None", "Current", "Custom"]
    private let locationManager = CLLocationManager()
    @State private var saveCurrentLocation: Bool = false
    
    @State private var wholeDay = false
    
    @State private var repetition = false
    let repetitionIntevals = ["Daily", "Weekly", "Monthly", "Yearly"]
    @State private var repetitionInterval = "Daily"
    let repeatUntilModes = ["Forever", "Repetitions", "End Date"]
    @State private var repeatUntil = "Forever"
    @State private var amountOfRepetitions = "10"
    @State private var foreverEvent = false
    @State private var deleteID = UUID()
    @State private var modifyID = UUID()
    
    @State private var notification = true
    @State private var notificationMinutesBefore = 5
    @State private var notficationTimeAtWholeDay = getDateFromHours(hours: "08:00")!
    
    @State private var currentRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @State private var customRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @ObservedObject var locationService: LocationService
    
    @Binding var saveEvent: Bool
    
    @Binding var showConfirmation: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ]
    ) var calendars: FetchedResults<MCalendar>
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var deleteEvents: FetchedResults<Event>
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var modifyEvents: FetchedResults<Event>
    
    var body: some View {
        if event.repetition{
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
                        TextField("Name", text: self.$event.name ?? "")
                            .padding()
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
                            if CLLocationManager.locationServicesEnabled() {
                                switch locationManager.authorizationStatus {
                                    case .notDetermined, .restricted, .denied:
                                    HStack{
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .padding()
                                            .foregroundColor(.yellow)
                                        Text("Please allow accurate location services in the settings to use this feature.")
                                        .padding()
                                        .foregroundColor(.blue)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .onAppear(){                                  saveCurrentLocation = false}
                                        Button(action: {
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                            }) {
                                    Image(systemName: "gear")
                                        .foregroundColor(.blue)
                                        .imageScale(.large)
                                            }
                                    }
                                    case .authorizedAlways, .authorizedWhenInUse:
                                        switch locationManager.accuracyAuthorization {
                                                case .fullAccuracy:
                                                    Map(coordinateRegion: $currentRegion, showsUserLocation: true, userTrackingMode: .constant(.follow),
                                                    annotationItems: markers) { marker in
                                                      marker.location
                                                  }.edgesIgnoringSafeArea(.all)
                                                    .frame(minHeight: 200)
                                                    .onAppear(){
                                                        saveCurrentLocation = true
                                                        let annotationCurrent = MKPointAnnotation()
                                                        annotationCurrent.coordinate = currentRegion.center
                                                        markers = [Marker(location: MapMarker(coordinate: currentRegion.center, tint: .red))]
                                                    }
                                                case .reducedAccuracy:
                                            HStack{
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .padding()
                                                    .foregroundColor(.yellow)
                                                Text("Please allow accurate location services in the settings to use this feature.")
                                                .padding()
                                                .foregroundColor(.blue)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .onAppear(){                                  saveCurrentLocation = false}
                                                Button(action: {
                                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                                    }) {
                                            Image(systemName: "gear")
                                                .foregroundColor(.blue)
                                                .imageScale(.large)
                                                    }
                                            }
                                                default:
                                                    Text("Error: This should not happen")
                                                    .padding()
                                                    .onAppear(){
                                                        saveCurrentLocation = false
                                                    }
                                            }
                                    @unknown default:
                                        Text("Error: This should not happen")
                                        .padding()
                                        .onAppear(){
                                            saveCurrentLocation = false
                                        }
                                }
                            } else {
                                Text("Location services are not enabled")
                                    .padding()
                                    .onAppear(){
                                        saveCurrentLocation = false
                                    }
                            }
                        }
                        if(location == "Custom"){
                            HStack{
                                Image(systemName: "magnifyingglass")
                                TextField("Search for location ...", text: $locationSearch)
                                    .autocapitalization(.none)
                                    .padding()
                                if locationService.status == .isSearching {
                                    Image(systemName: "clock")
                                        .foregroundColor(Color.gray)
                                }
                                if self.locationSearch != "" {
                                    Button(action: {
                                        self.locationSearch = ""
                                    })
                                    {
                                        Image(systemName: "multiply.circle")
                                            .foregroundColor(Color.gray)
                                    }
                                }
                            }
                            .onChange(of: locationSearch) { newValue in
                                locationService.queryFragment = locationSearch
                            }
                            Section() {
                                List {
                                    Group { () -> AnyView in
                                        switch locationService.status {
                                        case .noResults: return AnyView(Text("No Results").foregroundColor(Color(getAccentColorString())))
                                        case .error(let description): return AnyView(Text("Error: \(description)").foregroundColor(Color(getAccentColorString())))
                                        default: return AnyView(EmptyView())
                                        }
                                    }.foregroundColor(Color.gray)
                                    
                                    // display the results as a list
                                    ForEach(locationService.searchResults, id: \.self) {
                                        completionResult in
                                        Button(action: {
                                            self.locationSearch = completionResult.title + ", " + completionResult.subtitle
                                            let search =  MKLocalSearch(request: MKLocalSearch.Request(__naturalLanguageQuery: (completionResult.title + ", " + completionResult.subtitle)))
                                            search.start { (response, error) in
                                                let response = response!
                                                
                                                for item in response.mapItems {
                                                    if let name = item.name,
                                                       let location = item.placemark.location {
                                                        print("\(name): \(location.coordinate.latitude),\(location.coordinate.longitude)")
                                                        customRegion.center.latitude = location.coordinate.latitude
                                                        customRegion.center.longitude = location.coordinate.longitude
                                                        let annotation = MKPointAnnotation()
                                                        annotation.coordinate = customRegion.center
                                                    }
                                                }
                                                
                                                markers = [Marker(location: MapMarker(coordinate: customRegion.center, tint: .red))]
                                                
                                                self.locationService.queryFragment = ""
                                                self.locationService.clear()
                                            }
                                        }) {
                                            Text(completionResult.title + ", " + completionResult.subtitle).foregroundColor(Color(getAccentColorString()))
                                        }
                                        
                                        //Text(completionResult.title)
                                    }
                                }
                            }
                            Map(coordinateRegion: $customRegion,
                                annotationItems: markers) { marker in
                                marker.location
                            }.edgesIgnoringSafeArea(.all)
                                .frame(minHeight: 200)
                        }
                    }
                    Section{
                        HStack{
                            TextField("URL", text: $urlString)
                                .autocapitalization(.none)
                                .padding()
                        }
                        TextField("Notes", text: self.$event.notes ?? "")
                            .autocapitalization(.none)
                            .padding()
                    }
                }
                .navigationTitle("Edit Event")
                .toolbar {
                    Button("Delete") {
                        confirmationShown = true
                    }
                    .padding(.trailing, 5)
                    .foregroundColor(Color("AccentColorRed"))
                }
                .confirmationDialog(
                    "Are you sure?",
                    isPresented: $confirmationShown
                ) {
                    Button("Delete event"){
                        deleteEvent(id: event.key!)
                        dismiss()
                    }
                }
                .navigationBarItems(leading: Button(action : {
                    if event.repetition && repetition{
                        // Event is a repetition event and still be one
                        // Modify all events of repetition after event.startdate
                        
                        modifyID = event.repetitionID!
                        modifyEvents.nsPredicate = searchPredicateRepetitionIDModify(query: modifyID)
                        name = self.event.name!
                        
                        for mevent in modifyEvents{
                            mevent.setValue(name, forKey: "name")
                            mevent.setValue(wholeDay,forKey:"wholeDay")
                            mevent.setValue(self.event.notes,forKey:"notes")
                            
                            if(urlString != ""){
                                mevent.setValue(urlString.hasPrefix("http") ? urlString : "https://\(urlString)",forKey:"url")
                            }
                            
                            if (location == "Current"){
                                if saveCurrentLocation{
                                    mevent.setValue(true, forKey: "location")
                                    mevent.setValue(currentRegion.center.latitude, forKey: "latitude")
                                    mevent.setValue(currentRegion.center.longitude, forKey: "longitude")
                                    mevent.setValue(currentRegion.span.latitudeDelta, forKey: "latitudeDelta")
                                    mevent.setValue(currentRegion.span.longitudeDelta, forKey: "longitudeDelta")
                                }
                            } else if (location == "Custom")
                            {
                                mevent.setValue(true, forKey: "location")
                                mevent.setValue(customRegion.center.latitude, forKey: "latitude")
                                mevent.setValue(customRegion.center.longitude, forKey: "longitude")
                                mevent.setValue(customRegion.span.latitudeDelta, forKey: "latitudeDelta")
                                mevent.setValue(customRegion.span.longitudeDelta, forKey: "longitudeDelta")                            } else {
                                mevent.setValue(false, forKey: "location")
                            }
                            
                            if notification {
                                mevent.setValue(true,forKey:"notification")
                                if(!wholeDay){
                                    mevent.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                                } else {
                                    mevent.setValue(notficationTimeAtWholeDay,forKey:"notificationTimeAtWholeDay")
                                    mevent.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                                }
                                
                            } else{
                                mevent.setValue(false,forKey:"notification")
                            }
                        }
                        
                        if(repeatUntil == "Forever"){
                            let eventForever = ForeverEvent(context: moc)
                            eventForever.key = UUID()
                            eventForever.startdate = event.startdate!
                            eventForever.enddate = event.enddate!
                            eventForever.name = self.event.name
                            eventForever.url = event.url
                            eventForever.notes = event.notes
                            
                            if event.location{
                                eventForever.location = true
                                eventForever.latitude = event.latitude
                                eventForever.longitude = event.longitude
                                eventForever.latitudeDelta = event.latitudeDelta
                                eventForever.longitudeDelta = event.longitudeDelta
                            }else{
                                eventForever.location = false
                            }
                            if event.notification{
                                eventForever.notification = true
                                if(!event.wholeDay){
                                    eventForever.notificationMinutesBefore = event.notificationMinutesBefore
                                } else {
                                    eventForever.notificationTimeAtWholeDay = event.notificationTimeAtWholeDay
                                    eventForever.notificationMinutesBefore = event.notificationMinutesBefore
                                }
                            }else{
                                eventForever.notification = false
                            }
                            
                            eventForever.repetitionInterval = repetitionInterval
                            
                            calendars[calendar].addToForeverEvents(eventForever)
                            moc.delete(event)
                            foreverEvent = true
                            
                            deleteID = modifyID
                            deleteEvents.nsPredicate = searchPredicateRepetitionID(query: deleteID)
                            
                            for devent in deleteEvents{
                                moc.delete(devent)
                            }
                        }
                        
                        if !foreverEvent{
                            for mevent in modifyEvents{
                                calendars[calendar].addToEvents(mevent)
                            }
                        }
                        
                    } else {
                        // In this case event was a repeating event but should not be one anymore
                        // Notice that event cannot be an forever event
                        deleteID = event.repetitionID!
                        
                        let newEvent = Event(context: moc)
                        newEvent.key = UUID()
                        newEvent.name = self.event.name
                        newEvent.startdate = startDate
                        
                        if(endDate < startDate){
                            newEvent.enddate = startDate
                        } else{
                            newEvent.enddate = endDate
                        }
                        
                        newEvent.wholeDay = wholeDay
                        // make sure the protocol is set, such that the link works also without entering http:// or https:// at the beginning
                        if(urlString != ""){
                            newEvent.url = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
                            
                        }
                        if(notes != ""){
                            newEvent.notes = notes
                        }
                        if (location == "Current"){
                            if saveCurrentLocation{
                                newEvent.location = true
                                newEvent.latitude = currentRegion.center.latitude
                                newEvent.longitude = currentRegion.center.longitude
                                newEvent.latitudeDelta = currentRegion.span.latitudeDelta
                                newEvent.longitudeDelta = currentRegion.span.longitudeDelta
                            }
                        } else if (location == "Custom")
                        {
                            newEvent.location = true
                            newEvent.latitude = customRegion.center.latitude
                            newEvent.longitude = customRegion.center.longitude
                            newEvent.latitudeDelta = customRegion.span.latitudeDelta
                            newEvent.longitudeDelta = customRegion.span.longitudeDelta
                        } else {
                            newEvent.location = false
                        }
                        if notification {
                            newEvent.notification = true
                            if(!wholeDay){
                                newEvent.notificationMinutesBefore = Int32(notificationMinutesBefore)
                            } else {
                                newEvent.notificationTimeAtWholeDay = notficationTimeAtWholeDay
                                newEvent.notificationMinutesBefore = Int32(notificationMinutesBefore)
                            }
                            
                        } else {
                            newEvent.notification = false
                        }
                        
                        newEvent.repetition = false
                
                        calendars[calendar].addToEvents(newEvent)
                        
                        deleteEvents.nsPredicate = searchPredicateRepetitionID(query: deleteID)
                        
                        for devent in deleteEvents{
                            moc.delete(devent)
                        }
                    }
                    
                    try? moc.save()
                    WidgetCenter.shared.reloadAllTimelines()

                    withAnimation{
                        showConfirmation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation{
                            showConfirmation = false
                        }
                    }
                    
                    self.mode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image(systemName: "chevron.left")
                            .font(Font.headline.weight(.bold))
                            .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                        Text("Back")
                            .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                    }
                })
            }
            .onAppear {
                if event.key == nil{
                    dismiss()
                }else{
                    calendar = calendars.firstIndex(where: {$0.key == event.calendar?.key!})!
                    wholeDay = event.wholeDay
                    notification = event.notification
                    startDate = event.startdate!
                    endDate = event.enddate!
                    notification = event.notification
                    notificationMinutesBefore = Int(event.notificationMinutesBefore)
                    notficationTimeAtWholeDay = event.notificationTimeAtWholeDay ?? getDateFromHours(hours: "08:00")!
                    urlString = event.url ?? ""
                    notes = event.notes ?? ""
                    endRepetitionDate = event.repetitionEndDate ?? Date()
                    locationBool = event.location
                    if locationBool{
                        location = "Custom"
                        customRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        markers = [Marker(location: MapMarker(coordinate: customRegion.center, tint: .red))]
                    }
                    repetition = event.repetition
                    if repetition{
                        repeatUntil = event.repetitionUntil!
                        repetitionInterval = event.repetitionInterval!
                        if(repeatUntil == "Repetitions"){
                            amountOfRepetitions = String(event.repetitionAmount)
                        }
                        if(repeatUntil == "End Date"){
                            endRepetitionDate = event.repetitionEndDate!
                        }
                    }
                }
            }
        }else{
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
                        TextField("Name", text: self.$event.name ?? "")
                            .padding()
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
                            if CLLocationManager.locationServicesEnabled() {
                                switch locationManager.authorizationStatus {
                                    case .notDetermined, .restricted, .denied:
                                    HStack{
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .padding()
                                            .foregroundColor(.yellow)
                                        Text("Please allow accurate location services in the settings to use this feature.")
                                        .padding()
                                        .foregroundColor(.blue)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .onAppear(){                                  saveCurrentLocation = false}
                                        Button(action: {
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                            }) {
                                    Image(systemName: "gear")
                                        .foregroundColor(.blue)
                                        .imageScale(.large)
                                            }
                                    }
                                    case .authorizedAlways, .authorizedWhenInUse:
                                        switch locationManager.accuracyAuthorization {
                                                case .fullAccuracy:
                                                    Map(coordinateRegion: $currentRegion, showsUserLocation: true, userTrackingMode: .constant(.follow),
                                                    annotationItems: markers) { marker in
                                                      marker.location
                                                  }.edgesIgnoringSafeArea(.all)
                                                    .frame(minHeight: 200)
                                                    .onAppear(){
                                                        saveCurrentLocation = true
                                                        let annotationCurrent = MKPointAnnotation()
                                                        annotationCurrent.coordinate = currentRegion.center
                                                        markers = [Marker(location: MapMarker(coordinate: currentRegion.center, tint: .red))]
                                                    }
                                                case .reducedAccuracy:
                                            HStack{
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .padding()
                                                    .foregroundColor(.yellow)
                                                Text("Please allow accurate location services in the settings to use this feature.")
                                                .padding()
                                                .foregroundColor(.blue)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .onAppear(){                                  saveCurrentLocation = false}
                                                Button(action: {
                                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                                    }) {
                                            Image(systemName: "gear")
                                                .foregroundColor(.blue)
                                                .imageScale(.large)
                                                    }
                                            }
                                                default:
                                                    Text("Error: This should not happen")
                                                    .padding()
                                                    .onAppear(){
                                                        saveCurrentLocation = false
                                                    }
                                            }
                                    @unknown default:
                                        Text("Error: This should not happen")
                                        .padding()
                                        .onAppear(){
                                            saveCurrentLocation = false
                                        }
                                }
                            } else {
                                Text("Location services are not enabled")
                                    .padding()
                                    .onAppear(){
                                        saveCurrentLocation = false
                                    }
                            }
                        }
                        if(location == "Custom"){
                            HStack{
                                Image(systemName: "magnifyingglass")
                                TextField("Search for location ...", text: $locationSearch)
                                    .autocapitalization(.none)
                                    .padding()
                                if locationService.status == .isSearching {
                                    Image(systemName: "clock")
                                        .foregroundColor(Color.gray)
                                }
                                if self.locationSearch != "" {
                                    Button(action: {
                                        self.locationSearch = ""
                                    })
                                    {
                                        Image(systemName: "multiply.circle")
                                            .foregroundColor(Color.gray)
                                    }
                                }
                            }
                            .onChange(of: locationSearch) { newValue in
                                locationService.queryFragment = locationSearch
                            }
                            Section() {
                                List {
                                    Group { () -> AnyView in
                                        switch locationService.status {
                                        case .noResults: return AnyView(Text("No Results").foregroundColor(Color(getAccentColorString())))
                                        case .error(let description): return AnyView(Text("Error: \(description)").foregroundColor(Color(getAccentColorString())))
                                        default: return AnyView(EmptyView())
                                        }
                                    }.foregroundColor(Color.gray)
                                    
                                    // display the results as a list
                                    ForEach(locationService.searchResults, id: \.self) {
                                        completionResult in
                                        Button(action: {
                                            self.locationSearch = completionResult.title + ", " + completionResult.subtitle
                                            let search =  MKLocalSearch(request: MKLocalSearch.Request(__naturalLanguageQuery: (completionResult.title + ", " + completionResult.subtitle)))
                                            search.start { (response, error) in
                                                let response = response!
                                                
                                                for item in response.mapItems {
                                                    if let name = item.name,
                                                       let location = item.placemark.location {
                                                        print("\(name): \(location.coordinate.latitude),\(location.coordinate.longitude)")
                                                        customRegion.center.latitude = location.coordinate.latitude
                                                        customRegion.center.longitude = location.coordinate.longitude
                                                        let annotation = MKPointAnnotation()
                                                        annotation.coordinate = customRegion.center
                                                    }
                                                }
                                                
                                                markers = [Marker(location: MapMarker(coordinate: customRegion.center, tint: .red))]
                                                
                                                self.locationService.queryFragment = ""
                                                self.locationService.clear()
                                            }
                                        }) {
                                            Text(completionResult.title + ", " + completionResult.subtitle).foregroundColor(Color(getAccentColorString()))
                                        }
                                    }
                                }
                            }
                            Map(coordinateRegion: $customRegion,
                                annotationItems: markers) { marker in
                                marker.location
                            }.edgesIgnoringSafeArea(.all)
                                .frame(minHeight: 200)
                        }
                    }
                    Section{
                        HStack{
                            TextField("URL", text: $urlString)
                                .autocapitalization(.none)
                                .padding()
                        }
                        TextField("Notes", text: self.$event.notes ?? "")
                            .autocapitalization(.none)
                            .padding()
                    }
                }
                .navigationTitle("Edit Event")
                .toolbar {
                    Button("Delete") {
                        confirmationShown = true
                    }
                    .padding(.trailing, 5)
                    .foregroundColor(Color("AccentColorRed"))
                }
                .confirmationDialog(
                    "Are you sure?",
                    isPresented: $confirmationShown
                ) {
                    Button("Delete event"){
                        deleteEvent(id: event.key!)
                        dismiss()
                    }
                }
                .navigationBarItems(leading: Button(action : {
                    if event.repetition && repetition{
                        // Event is a repetition event and still be one
                        // Modify all events of repetition after event.startdate
                        modifyID = event.repetitionID!
                        modifyEvents.nsPredicate = searchPredicateRepetitionIDModify(query: modifyID)
                        name = self.event.name!
                        for mevent in modifyEvents{
                            mevent.setValue(name, forKey: "name")
                            mevent.setValue(wholeDay,forKey:"wholeDay")
                            mevent.setValue(self.event.notes,forKey:"notes")
                            
                            if(urlString != ""){
                                mevent.setValue(urlString.hasPrefix("http") ? urlString : "https://\(urlString)",forKey:"url")
                            }
                            
                            if (location == "Current"){
                                if saveCurrentLocation{
                                    mevent.setValue(true, forKey: "location")
                                    mevent.setValue(currentRegion.center.latitude, forKey: "latitude")
                                    mevent.setValue(currentRegion.center.longitude, forKey: "longitude")
                                    mevent.setValue(currentRegion.span.latitudeDelta, forKey: "latitudeDelta")
                                    mevent.setValue(currentRegion.span.longitudeDelta, forKey: "longitudeDelta")
                                }
                            } else if (location == "Custom")
                            {
                                mevent.setValue(true, forKey: "location")
                                mevent.setValue(customRegion.center.latitude, forKey: "latitude")
                                mevent.setValue(customRegion.center.longitude, forKey: "longitude")
                                mevent.setValue(customRegion.span.latitudeDelta, forKey: "latitudeDelta")
                                mevent.setValue(customRegion.span.longitudeDelta, forKey: "longitudeDelta")
                            } else {
                                mevent.setValue(false, forKey: "location")
                            }
                            
                            if notification {
                                mevent.setValue(true,forKey:"notification")
                                if(!wholeDay){
                                    mevent.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                                } else {
                                    mevent.setValue(notficationTimeAtWholeDay,forKey:"notificationTimeAtWholeDay")
                                    mevent.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                                }
                                
                            } else{
                                mevent.setValue(false,forKey:"notification")
                            }
                        }
                        
                        event.setValue(repeatUntil, forKey: "repetitionUntil")
                        event.setValue(repetitionInterval, forKey: "repetitionInterval")
                        if(repeatUntil == "Repetitions"){
                            event.setValue(Int16(amountOfRepetitions) ?? 10, forKey: "repetitionAmount")
                        }
                        if(repeatUntil == "End Date"){
                            event.setValue(endRepetitionDate, forKey: "repetitionEndDate")
                        }
                        
                        if(repeatUntil == "Forever"){
                            let eventForever = ForeverEvent(context: moc)
                            eventForever.key = UUID()
                            eventForever.startdate = event.startdate!
                            eventForever.enddate = event.enddate!
                            eventForever.name = self.event.name
                            eventForever.url = event.url
                            eventForever.notes = event.notes
                            
                            if event.location{
                                eventForever.location = true
                                eventForever.latitude = event.latitude
                                eventForever.longitude = event.longitude
                                eventForever.latitudeDelta = event.latitudeDelta
                                eventForever.longitudeDelta = event.longitudeDelta
                            }else{
                                eventForever.location = false
                            }
                            if event.notification{
                                eventForever.notification = true
                                if(!event.wholeDay){
                                    eventForever.notificationMinutesBefore = event.notificationMinutesBefore
                                } else {
                                    eventForever.notificationTimeAtWholeDay = event.notificationTimeAtWholeDay
                                    eventForever.notificationMinutesBefore = event.notificationMinutesBefore
                                }
                            }else{
                                eventForever.notification = false
                            }
                            
                            eventForever.repetitionInterval = repetitionInterval
                            
                            calendars[calendar].addToForeverEvents(eventForever)
                            moc.delete(event)
                            foreverEvent = true
                            
                            deleteID = modifyID
                            deleteEvents.nsPredicate = searchPredicateRepetitionID(query: deleteID)
                            
                            for devent in deleteEvents{
                                moc.delete(devent)
                            }
                        }
                        
                        if !foreverEvent{
                            for mevent in modifyEvents{
                                calendars[calendar].addToEvents(mevent)
                            }
                        }
                        
                    } else if event.repetition && !repetition{
                        // In this case event was a repeating event but should not be one anymore
                        // Notice that event cannot be an forever event
                        // Delete all events with repetitionID equal to event.repetitionID
                        // Create an new new event without repetitions
                        deleteID = event.repetitionID!
                        
                        let newEvent = Event(context: moc)
                        newEvent.key = UUID()
                        newEvent.name = self.event.name
                        newEvent.startdate = startDate
                        
                        if(endDate < startDate){
                            newEvent.enddate = startDate
                        } else{
                            newEvent.enddate = endDate
                        }
                        
                        newEvent.wholeDay = wholeDay
                        // make sure the protocol is set, such that the link works also without entering http:// or https:// at the beginning
                        if(urlString != ""){
                            newEvent.url = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
                            
                        }
                        if(notes != ""){
                            newEvent.notes = notes
                        }
                        if (location == "Current"){
                            if saveCurrentLocation{
                                newEvent.location = true
                                newEvent.latitude = currentRegion.center.latitude
                                newEvent.longitude = currentRegion.center.longitude
                                newEvent.latitudeDelta = currentRegion.span.latitudeDelta
                                newEvent.longitudeDelta = currentRegion.span.longitudeDelta
                            }
                        } else if (location == "Custom")
                        {
                            newEvent.location = true
                            newEvent.latitude = customRegion.center.latitude
                            newEvent.longitude = customRegion.center.longitude
                            newEvent.latitudeDelta = customRegion.span.latitudeDelta
                            newEvent.longitudeDelta = customRegion.span.longitudeDelta
                        } else {
                            newEvent.location = false
                        }
                        if notification {
                            newEvent.notification = true
                            if(!wholeDay){
                                newEvent.notificationMinutesBefore = Int32(notificationMinutesBefore)
                            } else {
                                newEvent.notificationTimeAtWholeDay = notficationTimeAtWholeDay
                                newEvent.notificationMinutesBefore = Int32(notificationMinutesBefore)
                            }
                            
                        } else {
                            newEvent.notification = false
                        }
                        
                        newEvent.repetition = false
                
                        calendars[calendar].addToEvents(newEvent)
                        
                        deleteEvents.nsPredicate = searchPredicateRepetitionID(query: deleteID)
                        
                        for devent in deleteEvents{
                            moc.delete(devent)
                        }
                    }else{
                        // In this case event was no repeating event
                        // Maybe it turns into an repeating event.
                        // If it turns into an repeating event we have to create more events
                        // Notice that the event can also turn into an forever event
                        if repetition{
                            event.setValue(wholeDay,forKey:"wholeDay")
                            event.setValue(startDate,forKey:"startdate")
                            event.setValue(endDate,forKey:"enddate")
                            event.setValue(self.event.notes,forKey:"notes")
                            
                            if(urlString != ""){
                                event.setValue(urlString.hasPrefix("http") ? urlString : "https://\(urlString)",forKey:"url")
                            }
                            
                            if (location == "Current"){
                                if saveCurrentLocation{
                                    event.setValue(true, forKey: "location")
                                    event.setValue(currentRegion.center.latitude, forKey: "latitude")
                                    event.setValue(currentRegion.center.longitude, forKey: "longitude")
                                    event.setValue(currentRegion.span.latitudeDelta, forKey: "latitudeDelta")
                                    event.setValue(currentRegion.span.longitudeDelta, forKey: "longitudeDelta")
                                }
                            } else if (location == "Custom")
                            {
                                event.setValue(true, forKey: "location")
                                event.setValue(customRegion.center.latitude, forKey: "latitude")
                                event.setValue(customRegion.center.longitude, forKey: "longitude")
                                event.setValue(customRegion.span.latitudeDelta, forKey: "latitudeDelta")
                                event.setValue(customRegion.span.longitudeDelta, forKey: "longitudeDelta")
                            } else {
                                event.setValue(false, forKey: "location")
                            }
                            
                            if notification {
                                event.setValue(true,forKey:"notification")
                                if(!wholeDay){
                                    event.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                                } else {
                                    event.setValue(notficationTimeAtWholeDay,forKey:"notificationTimeAtWholeDay")
                                    event.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                                }
                                
                            } else{
                                event.setValue(false,forKey:"notification")
                            }
                            
                            event.setValue(true, forKey: "repetition")
                            event.setValue(repeatUntil, forKey: "repetitionUntil")
                            event.setValue(repetitionInterval, forKey: "repetitionInterval")
                            let repetitionID = UUID()
                            event.setValue(repetitionID, forKey: "repetitionID")
                            let myCalendar = Calendar.current
                            if(repeatUntil == "Repetitions"){
                                event.setValue(Int16(amountOfRepetitions) ?? 10, forKey: "repetitionAmount")
                                let repetitionsNumber = event.repetitionAmount
                                if repetitionsNumber > 1{
                                    for i in 1...(repetitionsNumber-1) {
                                        var eventR = Event(context: moc)
                                        eventR.key = UUID()
                                        eventR = CopyEvent(event1: eventR, event2: event)
                                        switch repetitionInterval{
                                        case "Weekly":
                                            eventR.startdate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: event.startdate!)
                                            eventR.enddate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: event.enddate!)
                                        case "Daily":
                                            eventR.startdate = myCalendar.date(byAdding: .day, value: Int(i), to: event.startdate!)
                                            eventR.enddate = myCalendar.date(byAdding: .day, value: Int(i), to: event.enddate!)
                                            
                                        case "Monthly":
                                            eventR.startdate = myCalendar.date(byAdding: .month, value: Int(i), to: event.startdate!)
                                            eventR.enddate = myCalendar.date(byAdding: .month, value: Int(i), to: event.enddate!)
                                            
                                        case "Yearly":
                                            eventR.startdate = myCalendar.date(byAdding: .year, value: Int(i), to: event.startdate!)
                                            eventR.enddate = myCalendar.date(byAdding: .year, value: Int(i), to: event.enddate!)
                                            
                                        default:
                                            break
                                        }
                                        calendars[calendar].addToEvents(eventR)
                                    }
                                }
                            }
                            if(repeatUntil == "End Date"){
                                event.setValue(endRepetitionDate, forKey: "repetitionEndDate")
                                var currentDate = event.startdate
                                var i = 1
                                while currentDate! < endRepetitionDate{
                                    var eventR = Event(context: moc)
                                    eventR.key = UUID()
                                    eventR = CopyEvent(event1: eventR, event2: event)
                                    switch repetitionInterval{
                                    case "Weekly":
                                        eventR.startdate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: event.startdate!)
                                        eventR.enddate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: event.enddate!)
                                    case "Daily":
                                        eventR.startdate = myCalendar.date(byAdding: .day, value: Int(i), to: event.startdate!)
                                        eventR.enddate = myCalendar.date(byAdding: .day, value: Int(i), to: event.enddate!)
                                        
                                    case "Monthly":
                                        eventR.startdate = myCalendar.date(byAdding: .month, value: i, to: event.startdate!)
                                        eventR.enddate = myCalendar.date(byAdding: .month, value: i, to: event.enddate!)
                                        
                                    case "Yearly":
                                        eventR.startdate = myCalendar.date(byAdding: .year, value: Int(i), to: event.startdate!)
                                        eventR.enddate = myCalendar.date(byAdding: .year, value: Int(i), to: event.enddate!)
                                        
                                    default:
                                        break
                                    }
                                    currentDate = eventR.startdate
                                    if currentDate! <= endRepetitionDate{
                                        calendars[calendar].addToEvents(eventR)
                                        i = i + 1
                                    } else{
                                        moc.delete(eventR)
                                    }
                                }
                            }
                            if(repeatUntil == "Forever"){
                                let eventForever = ForeverEvent(context: moc)
                                eventForever.key = UUID()
                                eventForever.startdate = event.startdate!
                                eventForever.enddate = event.enddate!
                                eventForever.name = self.event.name
                                eventForever.url = event.url
                                eventForever.notes = event.notes
                                
                                if event.location{
                                    eventForever.location = true
                                    eventForever.latitude = event.latitude
                                    eventForever.longitude = event.longitude
                                    eventForever.latitudeDelta = event.latitudeDelta
                                    eventForever.longitudeDelta = event.longitudeDelta
                                }else{
                                    eventForever.location = false
                                }
                                if event.notification{
                                    eventForever.notification = true
                                    if(!event.wholeDay){
                                        eventForever.notificationMinutesBefore = event.notificationMinutesBefore
                                    } else {
                                        eventForever.notificationTimeAtWholeDay = event.notificationTimeAtWholeDay
                                        eventForever.notificationMinutesBefore = event.notificationMinutesBefore
                                    }
                                }else{
                                    eventForever.notification = false
                                }
                                
                                eventForever.repetitionInterval = repetitionInterval
                                
                                calendars[calendar].addToForeverEvents(eventForever)
                                moc.delete(event)
                                foreverEvent = true
                            }
                            
                            if !foreverEvent{
                                calendars[calendar].addToEvents(event)
                            }
                        }else{
                            event.setValue(wholeDay,forKey:"wholeDay")
                            event.setValue(startDate,forKey:"startdate")
                            event.setValue(endDate,forKey:"enddate")
                            
                            if(urlString != ""){
                                event.setValue(urlString.hasPrefix("http") ? urlString : "https://\(urlString)",forKey:"url")
                            }
                            
                            if (location == "Current"){
                                if saveCurrentLocation{
                                    event.setValue(true, forKey: "location")
                                    event.setValue(currentRegion.center.latitude, forKey: "latitude")
                                    event.setValue(currentRegion.center.longitude, forKey: "longitude")
                                    event.setValue(currentRegion.span.latitudeDelta, forKey: "latitudeDelta")
                                    event.setValue(currentRegion.span.longitudeDelta, forKey: "longitudeDelta")
                                }
                            } else if (location == "Custom")
                            {
                                event.setValue(true, forKey: "location")
                                event.setValue(customRegion.center.latitude, forKey: "latitude")
                                event.setValue(customRegion.center.longitude, forKey: "longitude")
                                event.setValue(customRegion.span.latitudeDelta, forKey: "latitudeDelta")
                                event.setValue(customRegion.span.longitudeDelta, forKey: "longitudeDelta")
                            } else {
                                event.setValue(false, forKey: "location")
                            }
                            
                            if notification {
                                event.setValue(true,forKey:"notification")
                                if(!wholeDay){
                                    event.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                                } else {
                                    event.setValue(notficationTimeAtWholeDay,forKey:"notificationTimeAtWholeDay")
                                    event.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                                }
                                
                            } else{
                                event.setValue(false,forKey:"notification")
                            }
                                
                            event.setValue(false, forKey: "repetition")
                            calendars[calendar].addToEvents(event)
                        }
                    }
                    
                    try? moc.save()
                    WidgetCenter.shared.reloadAllTimelines()

                    withAnimation{
                        showConfirmation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation{
                            showConfirmation = false
                        }
                    }
                    
                    self.mode.wrappedValue.dismiss()
                }){
                    HStack{
                        Image(systemName: "chevron.left")
                            .font(Font.headline.weight(.bold))
                            .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                        Text("Back")
                            .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                    }
                })
            }
            .onAppear {
                if event.key == nil{
                    // If the event is deleted, dismiss
                    dismiss()
                }else{
                    // Load the values of event
                    
                    calendar = calendars.firstIndex(where: {$0.key == event.calendar?.key!})!
                    wholeDay = event.wholeDay
                    notification = event.notification
                    startDate = event.startdate!
                    endDate = event.enddate!
                    notification = event.notification
                    notificationMinutesBefore = Int(event.notificationMinutesBefore)
                    notficationTimeAtWholeDay = event.notificationTimeAtWholeDay ?? getDateFromHours(hours: "08:00")!
                    urlString = event.url ?? ""
                    notes = event.notes ?? ""
                    endRepetitionDate = event.repetitionEndDate ?? Date()
                    locationBool = event.location
                    if locationBool{
                        location = "Custom"
                        customRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        markers = [Marker(location: MapMarker(coordinate: customRegion.center, tint: .red))]
                    }
                    repetition = event.repetition
                    if repetition{
                        repeatUntil = event.repetitionUntil!
                        repetitionInterval = event.repetitionInterval!
                        if(repeatUntil == "Repetitions"){
                            amountOfRepetitions = String(event.repetitionAmount)
                        }
                        if(repeatUntil == "End Date"){
                            endRepetitionDate = event.repetitionEndDate!
                        }
                    }
                }
            }
        }
    }
    
    // Option to delete event by UUID
    func deleteEvent(id: UUID)  {
        events.nsPredicate = NSPredicate(format: "key == %@", id as CVarArg)
        
        for event in events {
            moc.delete(event)
        }
        removeNotificationByUUID(eventuuid: id.uuidString)
        try? moc.save()
        WidgetCenter.shared.reloadAllTimelines()

    }
    
    // Search for events which the same repetition id
    // I.e. delete all events of the same repetition
    private func searchPredicateRepetitionID(query: UUID) -> NSPredicate? {
        return NSPredicate(format: "repetitionID == %@", query as CVarArg)
    }
    
    // Search for events which the same repetition id after the startdate of event
    // I.e. fetch all events of a repetition which should be modified the same way
    private func searchPredicateRepetitionIDModify(query: UUID) -> NSPredicate? {
        return NSPredicate(format: "repetitionID == %@ && startdate >= %@", query as CVarArg, event.startdate! as NSDate)
    }
    
    // Create a duplicate of an event (used for repetitions which are not forever)
    // Copys all values of event2 into event1 and returns event1
    func CopyEvent(event1: Event, event2: Event) -> Event{
        event1.name = event2.name
        event1.wholeDay = event2.wholeDay
        event1.url = event2.url
        event1.notes = event2.notes
        if event2.location{
            event1.location = true
            event1.latitude = event2.latitude
            event1.longitude = event2.longitude
            event1.latitudeDelta = event2.latitudeDelta
            event1.longitudeDelta = event2.longitudeDelta
        }else{
            event1.location = false
        }
        if event2.notification{
            event1.notification = true
            if(!event2.wholeDay){
                event1.notificationMinutesBefore = event2.notificationMinutesBefore
            } else {
                event1.notificationTimeAtWholeDay = event2.notificationTimeAtWholeDay
                event1.notificationMinutesBefore = event2.notificationMinutesBefore
            }
        }else{
            event1.notification = false
        }
        event1.repetition = event2.repetition
        if event2.repetition{
            event1.repetitionUntil = event2.repetitionUntil
            event1.repetitionInterval = event2.repetitionInterval
            event1.repetitionID = event2.repetitionID
            if(repeatUntil == "Repetitions"){
                event1.repetitionAmount = event2.repetitionAmount
            }else{
                event1.repetitionEndDate = event2.repetitionEndDate
            }
        }
        
        return event1
    }
}
