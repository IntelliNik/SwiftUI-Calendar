//
//  EditForeverEventView.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 19.01.22.
//

import SwiftUI
import MapKit

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
                    deleteForeverEvent(id: event.key!)
                    dismiss()
                }
            }
            .navigationBarItems(leading: Button(action : {
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
                    // TODO: save the name of the location somehow in event.locationName
                } else {
                    event.setValue(false, forKey: "location")
                }
                
                if notification {
                    event.setValue(true,forKey:"notification")
                    if(!wholeDay){
                        event.setValue(Int32(notificationMinutesBefore),forKey:"notificationMinutesBefore")
                    } else {
                        event.setValue(notficationTimeAtWholeDay,forKey:"notificationTimeAtWholeDay")
                    }
                    
                } else{
                    event.setValue(false,forKey:"notification")
                }
                
                calendars[calendar].addToForeverEvents(event)
                
                try? moc.save()
                
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
            locationBool = event.location
            if locationBool{
                location = "Custom"
                customRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                markers = [Marker(location: MapMarker(coordinate: customRegion.center, tint: .red))]
            }
        }
    }
    func deleteForeverEvent(id: UUID)  {
        events.nsPredicate = NSPredicate(format: "key == %@", id as CVarArg)
        
        for event in events {
            moc.delete(event)
        }
        try? moc.save()
    }
}

struct EditForeverEventView_Previews: PreviewProvider {
    static var previews: some View {
        EditForeverEventView(event: ForeverEvent(), locationService: LocationService(), saveEvent: .constant(true), showConfirmation: .constant(true))
    }
}
