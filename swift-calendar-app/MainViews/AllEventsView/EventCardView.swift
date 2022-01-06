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
    
    var body: some View {
        VStack{
            HStack{
                Text(event.name ?? "")
                // to keep the height for the edit button
                    .padding([.top, .bottom], 15)
                Spacer()
                if(event.notes != nil){
                    Image(systemName: "note.text")
                }
                if(event.location){
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
                        
                    }, label: {
                        Text("Edit")
                            .foregroundColor(.white)
                            .padding(10)
                    })
                        .background(Color(getAccentColor()))
                        .cornerRadius(45)
                }
            }.padding()
            Spacer()
            HStack{
                Text(event.startdate!, style: .date)
                Spacer()
                Image(systemName: "arrow.forward")
                Spacer()
                Text(event.enddate!, style: .date)
            }.padding()
            if(!event.wholeDay){
                HStack{
                    Text(event.startdate!, style: .time)
                    Spacer()
                    Image(systemName: "clock.fill")
                    Spacer()
                    Text(event.enddate!, style: .time)
                }.padding()
            }
        }
        .background(getColorFromString(stringColor: event.calendar?.color))
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
}

struct ExtendedEventCard: View{
    @State var event: Event
    
    var body: some View{
        VStack{
            EventCardView(event: event, editButton: true)
            if(event.location){
                let region = getRegionFromDatabase(latitude: event.latitude, longitude: event.longitude, latitudeDelta: event.latitudeDelta, longitudeDelta: event.longitudeDelta)
                Map(coordinateRegion: .constant(region))
                    .frame(height: 200)
            }
                if let urlString = event.url{
                    if(urlString != ""){
                        HStack{
                            Text("URL: ")
                            Spacer()
                            if let url = URL(string: urlString) {
                                Link(urlString, destination: url)
                            } else{
                                Text(urlString)
                                    .foregroundColor(.black)
                            }
                        }.padding()
                    }
                }
                if(event.notes != ""){
                    HStack{
                        Text("Notes: ")
                        Spacer()
                        Text(event.notes ?? "")
                    }.padding()
                }
            }
                .background(getColorFromString(stringColor: event.calendar?.color))
                .frame(maxWidth: .infinity, maxHeight: 800)
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
