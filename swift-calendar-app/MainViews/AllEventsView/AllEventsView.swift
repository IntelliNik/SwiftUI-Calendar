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
    
    @State var currentlyExtended: Event?
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    @Environment(\.colorScheme) var colorScheme
    
    
    // TODO: only for development, here the individual events should be included
    @State var showExtended = false
    
    var body: some View {
        ZStack(alignment: .leading){
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading){
                        ForEach(events, id: \.self) { event in
                            if(currentlyExtended == event){
                                ExtendedEventCard(event: event).onTapGesture(){
                                    withAnimation{
                                        currentlyExtended = nil
                                    }
                                }
                                .transition(.slide)
                            } else{
                                EventCardView(event: event, editButton: false).onTapGesture(){
                                    withAnimation{
                                        currentlyExtended = event
                                    }
                                }
                                .transition(.slide)
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
            }
        }
    }
    
    
    struct AllEventsView_Previews: PreviewProvider {
        static var previews: some View {
            AllEventsView()
        }
    }
}
