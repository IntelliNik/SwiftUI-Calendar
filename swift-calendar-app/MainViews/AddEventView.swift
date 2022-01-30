//
//  AddEventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 24.12.21.
//

import SwiftUI
import MapKit
import Combine

struct AddEventView: View {
    
    @State var datePickerComponents: DatePickerComponents = [.date, .hourAndMinute]
    
    @State private var name: String = ""
    @State private var urlString: String = ""
    let urlPrefixes = ["http://", "https://"]
    
    @State private var notes: String = ""
    
    @State private var calendar = 0
    
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date.now)!
    @State private var endRepetitionDate = Date()
    
    @State private var location: String = "None"
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
    
    @State private var notification = false
    @State private var notificationPermission = false
    @State private var notificationMinutesBefore = 5
    @State private var notficationTimeAtWholeDay = getDateFromHours(hours: "08:00")!
    
    @State private var currentRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @State private var customRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @State var confirmationShown = false
    
    @ObservedObject var locationService: LocationService
    
    @Binding var saveEvent: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ]
    ) var calendars: FetchedResults<MCalendar>
    
    func requestNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                notificationPermission = true
            } else if let error = error {
                notificationPermission = false
                print(error.localizedDescription)
            }
        }
    }
    
    func checkNotificationPermission(){
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { permission in
            if permission.authorizationStatus == .authorized  {
                notificationPermission = true
            }
            
        })
    }
    
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
                    Toggle("Notification", isOn: $notification)
                        .onChange(of: notification){ notification in
                            if notification{
                                checkNotificationPermission()
                            }
                        }
                        .padding()
                    if(notification){
                        if(!notificationPermission){
                            HStack{
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .padding()
                                    .foregroundColor(.yellow)
                                Text("Please allow to send notifications in the settings to use this feature.")
                                    .padding()
                                    .foregroundColor(.blue)
                                    .fixedSize(horizontal: false, vertical: true)
                                Button(action: {
                                    notification = false
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                }) {
                                    Image(systemName: "gear")
                                        .foregroundColor(.blue)
                                        .imageScale(.large)
                                }
                            }
                        } else{
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
                            case .notDetermined:
                                Text("").onAppear{
                                    location = "None"
                                    locationManager.requestWhenInUseAuthorization()
                                }
                            case .restricted, .denied:
                                HStack{
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .padding()
                                        .foregroundColor(.yellow)
                                    Text("Please allow accurate location services in the settings to use this feature.")
                                        .padding()
                                        .foregroundColor(.blue)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .onAppear(){
                                            saveCurrentLocation = false
                                        }
                                    Button(action: {
                                        location = "None"
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
                                            .onAppear(){
                                                saveCurrentLocation = false
                                            }
                                        Button(action: {
                                            location = "None"
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
                                        .onAppear(){                                  saveCurrentLocation = false}
                                }
                            @unknown default:
                                Text("Error: This should not happen")
                                    .padding()
                                    .onAppear(){                                  saveCurrentLocation = false}
                            }
                        } else {
                            Text("Location services are not enabled")
                                .padding()
                                .onAppear(){                                  saveCurrentLocation = false}
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
                                }.foregroundColor(Color(getAccentColorString()))
                                
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
                                        Text(completionResult.title + ", " + completionResult.subtitle)
                                            .foregroundColor(Color(getAccentColorString()))
                                    }
                                }
                            }
                        }
                        if(locationSearch != ""){
                            Map(coordinateRegion: $customRegion,
                                annotationItems: markers) { marker in
                                marker.location
                            }.edgesIgnoringSafeArea(.all)
                                .frame(minHeight: 200)
                        }
                    }
                }
                Section{
                    HStack{
                        TextField("URL", text: $urlString)
                            .autocapitalization(.none)
                            .padding()
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
                        } else {
                            event.name = "Event"
                        }
                        
                        event.startdate = startDate
                        
                        if(endDate < startDate){
                            event.enddate = startDate
                        } else{
                            event.enddate = endDate
                        }
                        
                        event.wholeDay = wholeDay
                        
                        // make sure the protocol is set, such that the link works also without entering http:// or https:// at the beginning
                        if(urlString != ""){
                            event.url = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
                            
                        }
                        if(notes != ""){
                            event.notes = notes
                        }
                        
                        if (location == "Current"){
                            if saveCurrentLocation{
                                event.location = true
                                event.latitude = currentRegion.center.latitude
                                event.longitude = currentRegion.center.longitude
                                event.latitudeDelta = currentRegion.span.latitudeDelta
                                event.longitudeDelta = currentRegion.span.longitudeDelta
                            }
                        } else if (location == "Custom")
                        {
                            event.location = true
                            event.latitude = customRegion.center.latitude
                            event.longitude = customRegion.center.longitude
                            event.latitudeDelta = customRegion.span.latitudeDelta
                            event.longitudeDelta = customRegion.span.longitudeDelta
                            // TODO: save the name of the location somehow in event.locationName
                        } else {
                            event.location = false
                        }
                        
                        /*if notification {
                         event.notification = true
                         if(!wholeDay){
                         event.notificationMinutesBefore = Int32(notificationMinutesBefore)
                         } else {
                         event.notificationTimeAtWholeDay = notficationTimeAtWholeDay
                         }
                         
                         }*/
                        if notification {
                            event.notification = true
                            if(!wholeDay){
                                event.notificationMinutesBefore = Int32(notificationMinutesBefore)
                            } else {
                                event.notificationTimeAtWholeDay = notficationTimeAtWholeDay
                                event.notificationMinutesBefore = Int32(notificationMinutesBefore)
                            }
                            
                        } else {
                            event.notification = false
                        }
                        
                        if repetition {
                            event.repetition = true
                            event.repetitionUntil = repeatUntil
                            event.repetitionInterval = repetitionInterval
                            let repetitionID = UUID()
                            event.repetitionID = repetitionID
                            let myCalendar = Calendar.current
                            if(repeatUntil == "Repetitions"){
                                event.repetitionAmount = Int16(amountOfRepetitions) ?? 10
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
                                        scheduleNotification(event: eventR)
                                    }
                                }
                            }
                            if(repeatUntil == "End Date"){
                                event.repetitionEndDate = endRepetitionDate
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
                                        scheduleNotification(event: eventR)
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
                                eventForever.name = event.name
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
                                    }
                                }else{
                                    eventForever.notification = false
                                }
                                
                                eventForever.repetitionInterval = repetitionInterval
                                
                                calendars[calendar].addToForeverEvents(eventForever)
                                scheduleNotification(event: eventForever)
                                moc.delete(event)
                                foreverEvent = true
                            }
                        } else {
                            event.repetition = false
                        }
                        
                        if !foreverEvent{
                            calendars[calendar].addToEvents(event)
                        }
                        
                        try! moc.save()
                        
                        if notification && !foreverEvent{
                            scheduleNotification(event: event)
                        }
                        
                        dismiss()
                    }.foregroundColor(Color(getAccentColorString(from: colorScheme)))
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
        .onAppear{
            requestNotificationPermission()
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func CopyEvent(event1: Event, event2: Event) -> Event{
        event1.name = event2.name
        event1.wholeDay = event2.wholeDay
        event1.url = event2.url
        event1.notes = event2.notes
        event1.notificationMinutesBefore = event2.notificationMinutesBefore
        
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

// This part is from the MapKit presentation of the seminar
// MapKit Code starts here

class LocationService: NSObject, ObservableObject {
    
    // Different search states
    enum LocationStatus: Equatable {
        case idle
        case noResults
        case isSearching
        case error(String)
        case result
    }
    
    // queryFragment used in view gets updated every time the user types something
    // default status is idle
    // searchResults contains all the results from the queries
    @Published var queryFragment: String = ""
    @Published private(set) var status: LocationStatus = .idle
    @Published private(set) var searchResults: [MKLocalSearchCompletion] = []
    
    private var queryCancellable: AnyCancellable?
    private let searchCompleter: MKLocalSearchCompleter!
    
    // initiate the search completer, set the delegate on self
    init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
        self.searchCompleter = searchCompleter
        super.init()
        self.searchCompleter.delegate = self
        self.searchCompleter.region = MKCoordinateRegion(.world)
        self.searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address, .pointOfInterest])
        
        
        // receive a stream from the queryFragment in the view
        // debounce (wait) for 500 milliseconds before pushing the event further
        // sink returns the updated string after waiting the specified amount of time
        queryCancellable = $queryFragment
            .receive(on: DispatchQueue.main)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main, options: nil)
            .sink(receiveValue: { fragment in
                
                // if fragment isn't empty then set the queryFrament to the current updated string
                self.status = .isSearching
                if !fragment.isEmpty {
                    self.searchCompleter.queryFragment = fragment
                } else {
                    self.status = .idle
                    self.searchResults = []
                }
            })
    }
}

// every time the queryFragment gets updated these functions get called
extension LocationService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // query the current input, filter out the results that have subtitles
        // results with no subtitles are usually countries and cities
        // remove filter if you want to get points of interest as well
        //self.searchResults = completer.results.filter({ $0.subtitle != "" })
        self.searchResults = completer.results
        self.status = completer.results.isEmpty ? .noResults : .result
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.status = .error(error.localizedDescription)
    }
    
    func clear() {
        self.searchResults = []
    }
}

// MapKit Code ends here

struct Marker: Identifiable {
    let id = UUID()
    var location: MapMarker
}
