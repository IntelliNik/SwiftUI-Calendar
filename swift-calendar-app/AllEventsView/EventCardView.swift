//
//  EventListView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 02.01.22.
//

import SwiftUI
import MapKit

struct EventCardView: View {
    @State var calendarColor: Color
    
    @State var name: String
    
    @State var wholeDay: Bool
    @State var startDate: Date
    @State var endDate: Date
    
    @State var repetition: Bool
    
    var body: some View {
        VStack{
            HStack{
                Text(name)
                Spacer()
                if(repetition){
                    Image(systemName: "repeat")
                }
            }.padding()
            Spacer()
            HStack{
                Text(startDate, style: .date)
                Spacer()
                Image(systemName: "arrow.forward")
                Spacer()
                Text(endDate, style: .date)
            }.padding()
            if(wholeDay){
                HStack{
                    Text(startDate, style: .time)
                    Spacer()
                    Image(systemName: "arrow.forward")
                    Spacer()
                    Text(endDate, style: .time)
                }.padding()
            }
            
        }
        .background(calendarColor)
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
}

struct ExtendedEventCard: View{
    @State var calendarColor: Color
    
    @State var name: String
    
    @State var wholeDay: Bool
    @State var startDate: Date
    @State var endDate: Date
    
    @State var repetition: Bool
    
    @State var location: Bool
    @State var locationRegion: MKCoordinateRegion
    
    @State var url: String
    @State var notes: String
    
    var body: some View{
        VStack{
            EventCardView(calendarColor: calendarColor, name: name, wholeDay: wholeDay, startDate: startDate, endDate: endDate, repetition: repetition)
            Spacer()
            if(location){
                Map(coordinateRegion: $locationRegion)
                    .frame(height: 200)
            }
            if(url != ""){
                HStack{
                    Text("URL: ")
                    Spacer()
                    Text(url)
                }.padding()
            }
            if(notes != ""){
                HStack{
                    Text("Notes: ")
                    Spacer()
                    Text(notes)
                }.padding()
            }
        }
        .background(calendarColor)
        .frame(maxWidth: .infinity, maxHeight: 800)
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
        VStack{
            EventCardView(calendarColor: .red, name: "Event 1", wholeDay: true, startDate: Date.now, endDate: Date.now, repetition: true)
            ExtendedEventCard(calendarColor: .blue, name: "Event 1", wholeDay: true, startDate: Date.now, endDate: Date.now, repetition: true, location: true, locationRegion: region,  url: "https:/apple.com", notes: "Hi Mom")
        }.padding()
    }
}
