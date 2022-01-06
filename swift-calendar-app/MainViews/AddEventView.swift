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
    //@State private var metadataView: MetadataView?
    
    @State private var notes: String = ""
    
    @State private var calendar = 0
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var endRepetitionDate = Date()
    
    @State private var location: String = "None"
    @State private var locationSearch = ""
    @State private var markers = [Marker(location: MapMarker(coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), tint: .red))]
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
    @State private var customRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @State var confirmationShown = false
    
    @ObservedObject var locationService: LocationService
    
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
                                    event.key = UUID()
                                    event.name = name
                                    event.startdate = startDate
                                    event.enddate = endDate
                                    event.wholeDay = wholeDay
                                    event.url = urlString
                                    event.notes = notes
                                    
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
                            TextField("Search for location ...", text: $locationSearch)
                                .autocapitalization(.none)
                                .padding()
                            Image(systemName: "magnifyingglass")
                            if locationService.status == .isSearching {
                                Image(systemName: "clock")
                                .foregroundColor(Color.gray)
                            }
                        }
                        .onChange(of: locationSearch) { newValue in
                            locationService.queryFragment = locationSearch
                         }
                        /*Section(header: Text("Search")) {
                            ZStack(alignment: .trailing) {
                                TextField("Search", text: $locationService.queryFragment)
                                
                                // while user is typing input it sends the current query to the location service
                                // which in turns sets its status to searching; when searching status is set on
                                // searching then a clock symbol will be shown beside the search box
                                if locationService.status == .isSearching {
                                    Image(systemName: "clock")
                                    .foregroundColor(Color.gray)
                                }
                            }
                        }*/
                        
                        Section() {
                            List {
                                Group { () -> AnyView in
                                    switch locationService.status {
                                        case .noResults: return AnyView(Text("No Results"))
                                        case .error(let description): return AnyView(Text("Error: \(description)"))
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
                                                Text(completionResult.title + ", " + completionResult.subtitle)
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
                    TextField("URL", text: $urlString)
                        .padding()
                        .autocapitalization(.none)
                        .onChange(of: urlString){ url in
                            //metadataView = MetadataView(vm: LinkViewModel(link: url))
                        }
                    TextField("Notes", text: $notes)
                        .autocapitalization(.none)
                        .padding()
                }
            }
        }
    }
}

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

struct Marker: Identifiable {
    let id = UUID()
    var location: MapMarker
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView(locationService: LocationService(), saveEvent: .constant(true))
    }
}
