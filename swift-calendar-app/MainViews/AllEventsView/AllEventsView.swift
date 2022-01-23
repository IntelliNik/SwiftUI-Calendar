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
    
    @State var currentlyExtended: Event?
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var showExtended = false
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("You have got \(events.count) Events stored")
                    .font(.caption)
                    .padding(.trailing)
            }
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
                    ScrollView() {
                        VStack(alignment: .leading){
                            ForEach(events, id: \.self) { event in
                                if(currentlyExtended == event){
                                    ExtendedEventCard(event: event).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = nil
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                } else{
                                    EventCardView(event: event, editButton: false, deleteButton: false).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = event
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
    }
    
    
    struct AllEventsView_Previews: PreviewProvider {
        static var previews: some View {
            AllEventsView()
        }
    }
}
