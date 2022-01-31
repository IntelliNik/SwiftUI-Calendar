//
//  EditForeverEventView.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 19.01.22.
//

import SwiftUI
import MapKit
import WidgetKit


struct EditForeverEventView: View {
    
    @State var datePickerComponents: DatePickerComponents = [.date, .hourAndMinute]
    
    @State var event: ForeverEvent
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
        entity: ForeverEvent.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ForeverEvent.startdate, ascending: true),
        ]
    ) var events: FetchedResults<ForeverEvent>
    
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
            .navigationTitle("Edit Forever Event")
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
                    // Call the delete function
                    deleteForeverEvent(id: event.key!)
                    dismiss()
                }
            }
            .navigationBarItems(leading: Button(action : {
                // Save the changes
                
                if repetition && repeatUntil == "Forever"{
                    //Event should stay an forever event
                    //Just modify the values of event
                    
                    event.setValue(wholeDay,forKey:"wholeDay")
                    event.setValue(startDate,forKey:"startdate")
                    if(endDate < startDate){
                        event.setValue(startDate,forKey:"enddate")
                    } else{
                        event.setValue(endDate,forKey:"enddate")
                    }
                    
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
                    
                    calendars[calendar].addToForeverEvents(event)
                }else{
                    // Event should not be an forever event anymore
                    // Transform the forever event into a normal event
                    // Code is similar to the one for add event
                    
                    let event2 = Event(context: moc)
                    event2.key = UUID()
                    event2.name = self.event.name
                    event2.startdate = startDate
                    
                    if(endDate < startDate){
                        event2.enddate = startDate
                    } else{
                        event2.enddate = endDate
                    }
                    
                    event2.wholeDay = wholeDay
                    if(urlString != ""){
                        event2.url = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
                        
                    }
                    if(notes != ""){
                        event2.notes = notes
                    }
                    if (location == "Current"){
                        if saveCurrentLocation{
                            event2.location = true
                            event2.latitude = currentRegion.center.latitude
                            event2.longitude = currentRegion.center.longitude
                            event2.latitudeDelta = currentRegion.span.latitudeDelta
                            event2.longitudeDelta = currentRegion.span.longitudeDelta
                        }
                    } else if (location == "Custom")
                    {
                        event2.location = true
                        event2.latitude = customRegion.center.latitude
                        event2.longitude = customRegion.center.longitude
                        event2.latitudeDelta = customRegion.span.latitudeDelta
                        event2.longitudeDelta = customRegion.span.longitudeDelta
                    } else {
                        event2.location = false
                    }
                    if notification {
                        event2.notification = true
                        if(!wholeDay){
                            event2.notificationMinutesBefore = Int32(notificationMinutesBefore)
                        } else {
                            event2.notificationTimeAtWholeDay = notficationTimeAtWholeDay
                            event2.notificationMinutesBefore = Int32(notificationMinutesBefore)
                        }
                        
                    } else {
                        event.notification = false
                    }
                    
                    if repetition {
                        event2.repetition = true
                        event2.repetitionUntil = repeatUntil
                        event2.repetitionInterval = repetitionInterval
                        let repetitionID = UUID()
                        event2.repetitionID = repetitionID
                        let myCalendar = Calendar.current
                        if(repeatUntil == "Repetitions"){
                            event2.repetitionAmount = Int16(amountOfRepetitions) ?? 10
                            let repetitionsNumber = event2.repetitionAmount
                            if repetitionsNumber > 1{
                                for i in 1...(repetitionsNumber-1) {
                                    var eventR = Event(context: moc)
                                    eventR.key = UUID()
                                    eventR = CopyEvent(event1: eventR, event2: event2)
                                    switch repetitionInterval{
                                    case "Weekly":
                                        eventR.startdate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: event2.startdate!)
                                        eventR.enddate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: event2.enddate!)
                                    case "Daily":
                                        eventR.startdate = myCalendar.date(byAdding: .day, value: Int(i), to: event2.startdate!)
                                        eventR.enddate = myCalendar.date(byAdding: .day, value: Int(i), to: event2.enddate!)
                                        
                                    case "Monthly":
                                        eventR.startdate = myCalendar.date(byAdding: .month, value: Int(i), to: event2.startdate!)
                                        eventR.enddate = myCalendar.date(byAdding: .month, value: Int(i), to: event2.enddate!)
                                        
                                    case "Yearly":
                                        eventR.startdate = myCalendar.date(byAdding: .year, value: Int(i), to: event2.startdate!)
                                        eventR.enddate = myCalendar.date(byAdding: .year, value: Int(i), to: event2.enddate!)
                                        
                                    default:
                                        break
                                    }
                                    calendars[calendar].addToEvents(eventR)
                                }
                            }
                        }
                        if(repeatUntil == "End Date"){
                            event2.repetitionEndDate = endRepetitionDate
                            var currentDate = event2.startdate
                            var i = 1
                            while currentDate! < endRepetitionDate{
                                var eventR = Event(context: moc)
                                eventR.key = UUID()
                                eventR = CopyEvent(event1: eventR, event2: event2)
                                switch repetitionInterval{
                                case "Weekly":
                                    eventR.startdate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: event2.startdate!)
                                    eventR.enddate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: event2.enddate!)
                                case "Daily":
                                    eventR.startdate = myCalendar.date(byAdding: .day, value: Int(i), to: event2.startdate!)
                                    eventR.enddate = myCalendar.date(byAdding: .day, value: Int(i), to: event2.enddate!)
                                    
                                case "Monthly":
                                    eventR.startdate = myCalendar.date(byAdding: .month, value: i, to: event2.startdate!)
                                    eventR.enddate = myCalendar.date(byAdding: .month, value: i, to: event2.enddate!)
                                    
                                case "Yearly":
                                    eventR.startdate = myCalendar.date(byAdding: .year, value: Int(i), to: event2.startdate!)
                                    eventR.enddate = myCalendar.date(byAdding: .year, value: Int(i), to: event2.enddate!)
                                    
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
                    } else {
                        event2.repetition = false
                    }
                    
                    calendars[calendar].addToEvents(event2)
                    
                    moc.delete(event)
                }

                updateNotification(event: event)    
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
            repetition = true
            repetitionInterval = event.repetitionInterval!
            repeatUntil = "Forever"
            locationBool = event.location
            if locationBool{
                location = "Custom"
                customRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                markers = [Marker(location: MapMarker(coordinate: customRegion.center, tint: .red))]
            }
        }
    }
    
    // Option to delete event by UUID
    func deleteForeverEvent(id: UUID)  {
        events.nsPredicate = NSPredicate(format: "key == %@", id as CVarArg)
        
        for event in events {
            moc.delete(event)
        }
        removeNotificationByUUID(eventuuid: id.uuidString)
        try? moc.save()
        WidgetCenter.shared.reloadAllTimelines()

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
