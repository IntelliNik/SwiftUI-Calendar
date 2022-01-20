//
//  WeekEventView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 13.01.22.
//

import SwiftUI

struct WeekEventView: View {
    @FetchRequest var events: FetchedResults<Event>
    
    @State var showEdit = false
    @State var eventIndex = 0
    
    var body: some View {
        ScrollView {
            ForEach(Array(zip(events.indices, events)), id: \.0) { index, event in
                HStack{
                    Text(event.name ?? "Event")
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer()
                    if let date = event.startdate{
                        if(!event.wholeDay){
                            Text(date, style: .time)
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                    }
                }
                .onTapGesture{
                    eventIndex = index
                    showEdit = true
                }
                .sheet(isPresented: $showEdit){
                    ShowEventView(event: events[eventIndex])
                }
                .padding(5)
                .background(getColorFromString(stringColor: event.calendar?.color))
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
