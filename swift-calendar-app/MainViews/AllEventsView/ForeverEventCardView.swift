//
//  ForeverEventCardView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 24.01.22.
//

import SwiftUI
import MapKit

let weekdays = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
let months = ["January","February","March","April","May","June","July","August","September","October","November","December"]

struct ForeverEventCardView: View {
    let event: ForeverEvent
    @State var editButton: Bool
    @State var deleteButton: Bool
    
    @State var showShowEvent = false
    
    @State var showConfirmation = false
    
    @State var saveEvent = false
    
    @State private var showingAlert = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: ForeverEvent.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ForeverEvent.name, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    var body: some View {
        VStack{
            HStack{
                Text(event.name ?? "")
                // to keep the height for the edit button
                    .padding([.top, .bottom], 15)
                Spacer()
                if (event.notes != nil && event.notes != "") {
                    Image(systemName: "note.text")
                }
                if (event.url != nil && event.url != "") {
                    Image(systemName: "globe")
                }
                if (event.location) {
                    Image(systemName: "location.fill")
                }
                if (event.notification) {
                    Image(systemName: "bell.fill")
                }
                Image(systemName: "infinity")
                if (editButton) {
                    Button(action: {
                        showShowEvent = true
                    }, label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                                .background(.white)
                                .clipShape(Circle())
                    }).padding(.leading, 5)
                }
                if(deleteButton){
                    Button(action: {
                        self.showingAlert = true
                    }, label: {
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.pink)
                            .background(.white)
                            .clipShape(Circle())
                    })
                }
            }.padding()
            Spacer()
            HStack{
                switch RepetitionInterval(rawValue: self.event.repetitionInterval ?? "Daily") {
                case .none:
                    Text("")
                case .some(.Daily):
                    DailyPresentationView(date: event.startdate ?? Date.now)
                case .some(.Weekly):
                    if event.wholeDay {
                        WeeklyWholeDayPresentationView(startdate: event.startdate ?? Date.now, startDateComponents: Calendar.current.dateComponents([.weekday], from: event.startdate ?? Date.now), enddateComponents: Calendar.current.dateComponents([.weekday], from: event.enddate ?? Date.now))
                    } else {
                        WeeklyPresentationView(startdate: event.startdate ?? Date.now, startDateComponents: Calendar.current.dateComponents([.weekday], from: event.startdate ?? Date.now))
                    }
                case .some(.Monthly):
                    if event.wholeDay {
                        MonthlyWholeDayPresentationView(startdate: event.startdate ?? Date.now, startDateComponents: Calendar.current.dateComponents([.year, .month, .day, .weekOfYear], from: event.startdate ?? Date.now), enddateComponents: Calendar.current.dateComponents([.weekday], from: event.enddate ?? Date.now))
                    } else {
                        MonthlyPresentationView(startdate: event.startdate ?? Date.now, startDateComponents: Calendar.current.dateComponents([.year, .month, .day, .weekOfYear], from: event.startdate ?? Date.now))
                    }
                case .some(.Yearly):
                    if event.wholeDay {
                        YearlyPresentationView(startdate: event.startdate ?? Date.now, startDateComponents: Calendar.current.dateComponents([.year, .month, .day, .weekOfYear], from: event.startdate ?? Date.now))
                    } else {
                        YearlyWholeDayPresentationView(startdate: event.startdate ?? Date.now, startDateComponents: Calendar.current.dateComponents([.year, .month, .day, .weekOfYear], from: event.startdate ?? Date.now), enddateComponents: Calendar.current.dateComponents([.year, .month, .day, .weekOfYear], from: event.enddate ?? Date.now))
                    }
                }
            }.padding()
            if(!event.wholeDay){
                HStack{
                    Text(event.startdate ?? Date.now, style: .time)
                    Spacer()
                    Image(systemName: "clock.fill")
                    Spacer()
                    Text(event.enddate ?? Date.now, style: .time)
                }.padding()
            }
        }
        .background(getColorFromString(stringColor: event.calendar?.color))
        .frame(maxWidth: .infinity, maxHeight: 200)
        /*.sheet(isPresented: $showShowEvent){
            ShowEventView(event: event)
        }*/
        .sheet(isPresented: $showShowEvent){
            EditForeverEventView(event: event,locationService: LocationService(),saveEvent: $saveEvent, showConfirmation: $showConfirmation)
        }
        .alert(isPresented: self.$showingAlert) {
            return Alert(
                title: Text(event.name ?? ""),
                   message: Text("Delete event?"),
                   primaryButton:
                        .cancel(),
                   secondaryButton: .destructive(
                       Text("Delete"),
                       action: {
                           deleteEvent(id: event.key!)
                           dismiss()
                       }
                   )
                )
            }
    }
    
    func deleteEvent(id: UUID)  {
        events.nsPredicate = NSPredicate(format: "key == %@", id as CVarArg)
        
        for event in events {
            moc.delete(event)
        }
        try? moc.save()
    }
}

struct ExtendedForeverEventCard: View{
    @State var event: ForeverEvent
    
    var body: some View {
        VStack{
            ForeverEventCardView(event: event, editButton: true, deleteButton: true)
            if(event.location){
                let region = getRegionFromDatabase(latitude: event.latitude, longitude: event.longitude, latitudeDelta: event.latitudeDelta, longitudeDelta: event.longitudeDelta)
                Map(coordinateRegion: .constant(region))
                    .frame(height: 200)
                    .padding([.bottom, .leading, .trailing])
            }
                if let urlString = event.url{
                    if(urlString != ""){
                        HStack{
                            Text("URL: ")
                            Spacer()
                            if let url = URL(string: urlString) {
                                Link(getURLwithoutProtocol(urlString: urlString), destination: url)
                                    .foregroundColor(.blue)
                            } else{
                                Text(urlString)
                                    .foregroundColor(.black)
                            }
                        }.padding()
                    }
                }
            if event.notes != nil && event.notes != ""{
                    HStack{
                        Text("Notes: ")
                        Spacer()
                        Text(event.notes ?? "")
                    }.padding()
                }
            }
            .background(getColorFromString(stringColor: event.calendar?.color))
            .frame(maxWidth: .infinity, maxHeight: 800)
            .padding(.bottom)
        }
    }


struct DailyPresentationView: View {
    let date: Date
    
    var body: some View {
        HStack{
            Text("Every day starting on:")
            Spacer()
            Text(date, style: .date)
        }
    }
}

struct WeeklyPresentationView: View {
    let startdate: Date
    let startDateComponents: DateComponents
    
    var body: some View {
        HStack{
            Text("Every \(weekdays[startDateComponents.weekday ?? 0]) starting on:")
            Spacer()
            Text(startdate, style: .date)
        }
    }
}

struct WeeklyWholeDayPresentationView: View {
    let startdate: Date
    let startDateComponents: DateComponents
    let enddateComponents: DateComponents
    
    var body: some View {
        VStack {
            Text("Every week from \(weekdays[startDateComponents.weekday ?? 0]) until \(weekdays[enddateComponents.weekday ?? 0])")
            Spacer()
            HStack {
                Text("Starting on:")
                Spacer()
                Text(startdate, style: .date)
            }
            Spacer()
        }.padding()
    }
}

struct MonthlyPresentationView: View {
    let startdate: Date
    let startDateComponents: DateComponents
    
    var body: some View {
        VStack {
            HStack {
                Text("Every month on the \(startDateComponents.day ?? 1)\(finStr(startDateComponents.day ?? 0))")
                Spacer()
            }
            Spacer()
            HStack{
                Text("starting on:")
                Spacer()
                Text(startdate, style: .date)
            }
        }
    }
}

struct MonthlyWholeDayPresentationView: View {
    let startdate: Date
    let startDateComponents: DateComponents
    let enddateComponents: DateComponents
    
    var body: some View {
        VStack {
            HStack {
                Text("Every month from the \(startDateComponents.day ?? 1)\(finStr(startDateComponents.day ?? 0)) to the \(enddateComponents.day ?? 1)\(finStr(enddateComponents.day ?? 0))")
            }
            Spacer()
            HStack {
                Text("Starting on:")
                Spacer()
                Text(startdate, style: .date)
            }
            Spacer()
        }
    }
}

struct YearlyPresentationView: View {
    let startdate: Date
    let startDateComponents: DateComponents
    
    var body: some View {
        HStack{
            Text("Every year on the \(startDateComponents.day ?? 1)\(finStr(startDateComponents.day ?? 0)) of \(months[startDateComponents.month ?? 1]) starting on:")
            Spacer()
            Text(startdate, style: .date)
        }
    }
}

struct YearlyWholeDayPresentationView: View {
    let startdate: Date
    let startDateComponents: DateComponents
    let enddateComponents: DateComponents
    
    var body: some View {
        VStack {
            HStack {
                Text("Every year from the \(startDateComponents.day ?? 1)\(finStr(startDateComponents.day ?? 0)) of \(months[startDateComponents.month ?? 1]) to the \(enddateComponents.day ?? 1)\(finStr(enddateComponents.day ?? 0)) of \(months[enddateComponents.month ?? 1])")
            }
            Spacer()
            HStack {
                Text("Starting on:")
                Spacer()
                Text(startdate, style: .date)
            }
            Spacer()
        }
    }
}
    
/*
    struct EventListView_Previews: PreviewProvider {
        static var previews: some View {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            VStack{
                //EventCardView(calendarColor: .red, name: "Event 1", wholeDay: true, startDate: //Date.now, endDate: Date.now, repetition: true)
                /*
                 ExtendedEventCard(calendarColor: .blue, name: "Event 1", wholeDay: true, startDate: Date.now, endDate: Date.now, repetition: true, location: true, locationRegion: region,  url: "https:/apple.com", notes: "Hi Mom")
                 */
            }.padding()
        }
    }

*/
