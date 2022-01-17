//
//  EventListView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 02.01.22.
//

import SwiftUI
import MapKit

struct EventCardView: View {
    @State var event: Event
    @State var editButton: Bool
    @State var deleteButton: Bool
    
    @State var showShowEvent = false
    
    @State var showConfirmation = false
    
    @State var saveEvent = false
    
    @State private var showingAlert = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.name, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    var body: some View {
        VStack{
            HStack{
                Text(event.name ?? "")
                // to keep the height for the edit button
                    .padding([.top, .bottom], 15)
                Spacer()
                if event.notes != nil && event.notes != ""{
                    Image(systemName: "note.text")
                }
                if event.url != nil && event.url != ""{
                    Image(systemName: "globe")
                }
                if(event.location){
                    Image(systemName: "location.fill")
                }
                if(event.notification){
                    Image(systemName: "bell.fill")
                }
                if(event.repetition){
                    Image(systemName: "repeat")
                }
                if(editButton){
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
                Text(event.startdate ?? Date.now, style: .date)
                Spacer()
                Image(systemName: "arrow.forward")
                Spacer()
                Text(event.enddate ?? Date.now, style: .date)
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
            EditEventView(event: event,locationService: LocationService(),saveEvent: $saveEvent, showConfirmation: $showConfirmation)
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

struct ExtendedEventCard: View{
    @State var event: Event
    
    func getURLwithoutProtocol(urlString: String) -> String{
        if(urlString.hasPrefix("http://")){
            return String(urlString.dropFirst(7))
        }
        if(urlString.hasPrefix("https://")){
            return String(urlString.dropFirst(8))
        }
        return urlString
    }
    
    var body: some View{
        VStack{
            EventCardView(event: event, editButton: true, deleteButton: true)
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
