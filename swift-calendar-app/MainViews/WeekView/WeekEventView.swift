//
//  WeekEventView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 13.01.22.
//

import SwiftUI

struct WeekEventView: View {
    @FetchRequest var events: FetchedResults<Event>
    
    var body: some View {
        ScrollView {
            ForEach(events, id: \.self) { event in
                Text(event.name ?? "None")
                    .foregroundColor(.none)
            }
        }
    }
    
    init(filter: DateComponents) {
        _events = FetchRequest<Event>(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
            ],
            // Forceunwrap might break!
            predicate: NSPredicate(format: "startdate <= %@ AND %@ <= enddate", getDateForStartdateComparison(from: filter)! as CVarArg, getDateForEnddateComparison(from: filter)! as CVarArg)
        )
        
    }
}

/*struct WeekEventView_Previews: PreviewProvider {
    static var previews: some View {
        WeekEventView(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now))
    }
}*/
