//
//  AllRepeatingEventsView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 24.01.22.
//

import SwiftUI
import MapKit


struct AllRepeatingEventsView: View {
    @State private var scrollTargetTodayButton: UUID?
    @State private var showMenu = false
    @State private var showAddEventSheet = true
    
    @State private var refreshID = UUID()
    
    @State var currentlyExtended: (Event?, ForeverEvent?) = (nil, nil)
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "enddate >= %@ && repetitionInterval == %@", getEndOfDay(date: Date.now) as NSDate, "daily")
    ) var eventsDaily: FetchedResults<Event>
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "enddate >= %@ && repetitionInterval == %@", getEndOfDay(date: Date.now) as NSDate, "weekly")
    ) var eventsWeekly: FetchedResults<Event>
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "enddate >= %@ && repetitionInterval == %@", getEndOfDay(date: Date.now) as NSDate, "monthly")
    ) var eventsMonthly: FetchedResults<Event>
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "enddate >= %@ && repetitionInterval == %@", getEndOfDay(date: Date.now) as NSDate, "yearly")
    ) var eventsYearly: FetchedResults<Event>
    
    @FetchRequest(
        entity: ForeverEvent.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ForeverEvent.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "repetitionInterval == %@", "daily")
    ) var fEventsDaily: FetchedResults<ForeverEvent>
    
    @FetchRequest(
        entity: ForeverEvent.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ForeverEvent.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "repetitionInterval == %@", "weekly")
    ) var fEventsWeekly: FetchedResults<ForeverEvent>
    
    @FetchRequest(
        entity: ForeverEvent.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ForeverEvent.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "repetitionInterval == %@", "monthly")
    ) var fEventsMonthly: FetchedResults<ForeverEvent>
    
    @FetchRequest(
        entity: ForeverEvent.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ForeverEvent.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "repetitionInterval == %@", "yearly")
    ) var fEventsYearly: FetchedResults<ForeverEvent>
    
    @Environment(\.colorScheme) var colorScheme
    
    
    // TODO: only for development, here the individual events should be included
    @State var showExtended = false
    
    var body: some View {
        /*
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
         */
        ZStack(alignment: .leading){
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading){
                        if (eventsDaily.count > 0) {
                            Text("Current daily events")
                            
                            ForEach(eventsDaily, id: \.self) { event in
                                
                                //event.repetitionInterval
                                if(currentlyExtended.0 == event){
                                    ExtendedEventCard(event: event).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = (nil,nil)
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                } else{
                                    EventCardView(event: event, editButton: false, deleteButton: false).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = (event,nil)
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                }
                            }
                            .onChange(of: refreshID) { _ in
                                
                             }
                        }
                        
                        if (fEventsDaily.count > 0) {
                            
                            Text("Permanent daily events")
                            
                            ForEach(fEventsDaily, id: \.self) { event in
                                
                                if(currentlyExtended.1 == event){
                                    ExtendedForeverEventCard(event: event).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = (nil,nil)
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                } else{
                                    ForeverEventCardView(event: event, editButton: false, deleteButton: false).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = (nil,event)
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                }
                            }
                            .onChange(of: refreshID) { _ in
                                
                             }
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
    
    
    struct AllRepeatingEventsView_Previews: PreviewProvider {
        static var previews: some View {
            AllRepeatingEventsView()
        }
    }
}
