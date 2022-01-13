//
//  WeekEventView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 13.01.22.
//

import SwiftUI

struct WeekEventView: View {
    @State var dateComponents: DateComponents
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    var body: some View {
        ScrollView/*(.vertical, showsIndicators: false)*/ {
            //VStack {
                ForEach(events, id: \.self) { event in
                    Text(event.name ?? "None")
                        .foregroundColor(.none)
                }
            //}
        }
    }
}

struct WeekEventView_Previews: PreviewProvider {
    static var previews: some View {
        WeekEventView(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now))
    }
}
