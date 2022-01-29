//
//  DayViewEachHour.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 18.01.22.
//

import SwiftUI

struct DayViewEachHour: View {
    let eventsThisHour: [AbstractEvent]
    
    @State var showEventSheet = false
    
    @State var eventHourToEdit = 0
    @State var eventIndexToShow = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(){
                ForEach(Array(zip(eventsThisHour.indices, eventsThisHour)), id: \.0) { index, abstractEvent in
                    if let event = abstractEvent as? Event {
                        EventView(event: event)
                            .onTapGesture(){
                                eventIndexToShow = index
                                showEventSheet = true
                        }
                    }
                    if let fEvent = abstractEvent as? ForeverEvent {
                        ForeverEventView(event: fEvent)
                            .onTapGesture(){
                                eventIndexToShow = index
                                showEventSheet = true
                        }
                    }
                }

            }
        }.padding(.trailing, 30)
            .sheet(isPresented: $showEventSheet){
                if eventsThisHour[eventIndexToShow] is Event {
                    ShowEventView(event: eventsThisHour[eventIndexToShow] as! Event)
                } else {
                    ShowForeverEventView(event: eventsThisHour[eventIndexToShow] as! ForeverEvent)
                }
            }
    }
}
