//
//  SwiftUIView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 19.12.21.
//

import SwiftUI
import MapKit
import CoreData


struct AllEventsView: View {
    @State private var scrollTargetTodayButton: UUID?
    @State private var showMenu = false
    @State private var showAddEventSheet = true
    
    @State private var refreshID = UUID()
    
    @State var currentlyExtended: Event?
    
    @FetchRequest var events: FetchedResults<Event>
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var showExtended = false
    
    
    var limit = 50
    @State var offset = 0
    
    init() {
        let request = Event.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true)
        ]
        
        _events = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack{
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
            }else{
                HStack{
                    Button(action:{
                        if(offset >= limit){
                            withAnimation{
                                offset = offset - limit
                            }
                        }else{
                            withAnimation{
                                offset = 0
                            }
                        }
                    }){
                        Image(systemName: "arrow.left")
                            .padding(.leading)
                    }
                    Spacer()
                    Text("Showing \(offset) - \(events.count <= offset + limit ? events.count : offset + limit) of \(events.count) stored events")
                        .lineLimit(1)
                        .font(.caption)
                        .padding()
                    Spacer()
                    Button(action:{
                        withAnimation{
                            if(events.count >= limit){
                                offset = min(offset + limit, events.count - limit)
                            }
                        }
                    }){
                        Image(systemName: "arrow.right")
                            .padding(.trailing)
                    }
                }
            }
            ZStack(alignment: .leading){
                ScrollViewReader { reader in
                    ScrollView() {
                        VStack(alignment: .leading){
                            ForEach(min(offset, min(events.count, offset+limit))..<min(events.count, offset+limit), id: \.self) { index in
                                if(currentlyExtended == events[index]){
                                    ExtendedEventCard(event: events[index]).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = nil
                                        }
                                    }
                                    .transition(.slide)
                                    .onAppear {
                                        self.refreshID = UUID()
                                    }
                                } else{
                                    EventCardView(event: events[index], editButton: false, deleteButton: false).onTapGesture(){
                                        withAnimation{
                                            currentlyExtended = events[index]
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
    
    func loadBatch(offset: Int, limit: Int){
        let request = Event.fetchRequest()
        
        request.fetchLimit = limit
        request.fetchOffset = offset
        
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true)
        ]
    }
    
    
    struct AllEventsView_Previews: PreviewProvider {
        static var previews: some View {
            AllEventsView()
        }
    }
}
