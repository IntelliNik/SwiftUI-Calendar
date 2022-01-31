//
//  DayViewEachHour.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 18.01.22.
//

import SwiftUI

struct DayViewEachHour: View {
    let eventsThisHour: [Event]
    @State var showEventSheet = false
    @State var eventHourToEdit = 0
    @State var eventIndexToShow = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(){
                ForEach(Array(zip(eventsThisHour.indices, eventsThisHour)), id: \.0) { index, event in
                    EventView(event: event)
                        .onTapGesture(){
                            eventIndexToShow = index
                            showEventSheet = true
                    }
                }

            }
        }.padding(.trailing, 30)
            .sheet(isPresented: $showEventSheet){
                ShowEventView(event: eventsThisHour[eventIndexToShow])
            }
    }
}
