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
    
    @State var showShowEvent = false
    
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
                        // TODO: should later directly link to Edit instead of "Show"
                        Text("Show")
                            .foregroundColor(.white)
                            .padding(10)
                    })
                        .background(Color(getAccentColorString()))
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
        .sheet(isPresented: $showShowEvent){
            ShowEventView(event: event)
        }
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
            EventCardView(event: event, editButton: true)
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
