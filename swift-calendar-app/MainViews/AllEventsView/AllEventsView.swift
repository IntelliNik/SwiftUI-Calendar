//
//  SwiftUIView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 19.12.21.
//

import SwiftUI
import MapKit


struct AllEventsView: View {
    @StateObject var dataSource = DayDataModel()
     
    @State private var scrollTargetTodayButton: UUID?
    @State private var showMenu = false
    @State private var showAddEventSheet = true
    
    @Environment(\.colorScheme) var colorScheme
    
    
    // TODO: only for development, here the individual events should be included
    @State var showExtended = false
    @State var event =                             EventCardView(calendarColor: .red, name: "Event 1", wholeDay: true, startDate: Date.now, endDate: Date.now, repetition: true)
    
    @State var extendedEvent =                             ExtendedEventCard(calendarColor: .blue, name: "Event 1", wholeDay: true, startDate: Date.now, endDate: Date.now, repetition: true, location: true, locationRegion: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)),  url: "https://rwth.zoom.us", notes: "Hi Mom")
    
    var body: some View {
        ZStack(alignment: .leading){
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading){
                        Text("All Events")
                            .font(.system(size: 20, weight: .heavy))
                            .padding()
                        Spacer()
                        ForEach(dataSource.items) { item in
                            Text(item.date!, style: .date)
                                .padding(.top, 30)
                                .padding(.leading, 10)
                                .onAppear {
                                    dataSource.loadMoreContentIfNeeded(currentDate: item)
                                }
                            if(showExtended){
                                extendedEvent.onTapGesture {
                                    showExtended.toggle()
                                }
                            } else {
                                event.onTapGesture {
                                    showExtended.toggle()
                                }
                            }
                        }
                    }.navigationTitle("All Events")
                }
                .onAppear(){
                    // TODO: not working....
                    reader.scrollTo(dataSource.getIdentifyableToday()?.id)
                }
                .onChange(of: scrollTargetTodayButton) { target in
                    if let target = target {
                        // reset scroll target
                        scrollTargetTodayButton = nil
                        withAnimation {
                            reader.scrollTo(target, anchor: .top)
                        }
                    }
                }
            }
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                        if let today = dataSource.getIdentifyableToday(){
                            scrollTargetTodayButton = today.id
                        }
                    }, label: {
                        Text("Today")
                            .font(.system(.title))
                            .foregroundColor(.white)
                            .padding(10)
                    })
                        .background(Color(getAccentColor()))
                        .cornerRadius(45)
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                        .padding(20)
                }
            }.ignoresSafeArea()
        }
    }
    
    
    struct EndlessListView_Previews: PreviewProvider {
        static var previews: some View {
            AllEventsView()
        }
    }
}
