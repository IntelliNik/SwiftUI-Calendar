//
//  SwiftUIView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 19.12.21.
//

import SwiftUI
import MapKit


struct AllEventsView: View {
    @State private var scrollTargetTodayButton: UUID?
    @State private var showMenu = false
    @State private var showAddEventSheet = true
    
    @State private var refreshID = UUID()
    
    @State var currentlyExtended: (Event?, ForeverEvent?) = (nil, nil)
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    @FetchRequest(
        entity: ForeverEvent.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ForeverEvent.startdate, ascending: true),
        ]
    ) var fEvents: FetchedResults<ForeverEvent>
    
    @Environment(\.colorScheme) var colorScheme
    
    
    // TODO: only for development, here the individual events should be included
    @State var showExtended = false
    
    var body: some View {
        if(events.count == 0){
            GeometryReader{geo in
            HStack(alignment: .top){
                Spacer()
                VStack(alignment: .trailing){
                    Image("arrow")
                        .resizable()
                        .frame(width: 96.0, height: 96.0)
                        .padding(.trailing, 50)
                    Text("It looks like you don't have any events yet, click here to add one!")
                        .font(.caption)
                        .frame(width: geo.size.width/2, height: geo.size.height/2, alignment: .top)
                        .padding(.trailing, 50)
                    Spacer()
                }
            }
            }
        }
        ZStack(alignment: .leading){
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading){
                        ForEach(combine(events, and: fEvents), id: \.self) { abstractEvent in
                            if let event = abstractEvent as? Event {
                                if(currentlyExtended.0 == event) {
                                    ExtendedEventCard(event: event).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = (nil, nil)
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                } else {
                                    EventCardView(event: event, editButton: false, deleteButton: false).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = (event, nil)
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                }
                            } else if let fEvent = abstractEvent as? ForeverEvent {
                                if(currentlyExtended.1 == fEvent){
                                    ExtendedForeverEventCard(event: fEvent).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = (nil, nil)
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                } else {
                                    ForeverEventCardView(event: fEvent, editButton: false, deleteButton: false).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = (nil, fEvent)
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                }
                            }
                        }
                        .onChange(of: refreshID) { _ in
                            
                         }
                    }.navigationTitle("All Events")
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
                .onChange(of: refreshID) { _ in
                    
                 }
            }
            .onChange(of: refreshID) { _ in
                
             }
        }
    }
    
    
    struct AllEventsView_Previews: PreviewProvider {
        static var previews: some View {
            AllEventsView()
        }
    }
}
