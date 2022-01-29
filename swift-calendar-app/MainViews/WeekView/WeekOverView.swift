//
//  WeekOverView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 29.01.22.
//

import SwiftUI

struct WeekOverView: View {
    @FetchRequest var eventsWeek: FetchedResults<Event>
    //@FetchRequest var eventsDay: FetchedResults<Event>
    
    private let dateComponent: DateComponents
    private let foreverEventsToShow: [ForeverEvent]
    
    //@EnvironmentObject var currentTime: CurrentTime
    
    var body: some View {
        Text("\(eventsWeek.count + foreverEventsToShow.count) events this week")
    }
    
    init(filter: DateComponents, foreverEvents: FetchedResults<ForeverEvent>) {
        /*
        _eventsWeek = FetchRequest<Event>(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
            ],
            // Forceunwrap might break!
            predicate: NSPredicate(format: "startdate <= %@ AND %@ <= enddate", getDateForStartdateComparison(from: filter)! as CVarArg, getDateForEnddateComparison(from: filter)! as CVarArg)
        )
         */
        print("Init")
        print(filter)
        let beginningOfWeek = getBeginningOfWeek(from: filter)
        print(beginningOfWeek)
        let endOfWeek = getBeginningOfNextWeek(from: filter)
        print(endOfWeek)
        print("")
        //@FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
        //var foreverEvents: FetchedResults<ForeverEvent>
        
        _eventsWeek = FetchRequest<Event>(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
            ],
            // Forceunwrap might break!
            predicate: NSPredicate(format: "(startdate < %@ AND %@ <= enddate) OR (startdate < %@ AND enddate >= %@) OR (startdate >= %@ AND enddate <= %@)", beginningOfWeek as CVarArg, beginningOfWeek as CVarArg, endOfWeek as CVarArg, endOfWeek as CVarArg, beginningOfWeek as CVarArg, endOfWeek as CVarArg)
        )
        
        self.dateComponent = filter
        
        var foreverEventsThisWeek: [ForeverEvent] = []
        
        for i in 0...6 {
            foreverEventsThisWeek.append(contentsOf: getDayEventsFromForeverEvents(events: foreverEvents, datecomponent: Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year, .weekday, .weekOfYear], from: Calendar.current.date(byAdding: .day, value: i, to: beginningOfWeek) ?? Date.now)))
        }
        
        self.foreverEventsToShow = foreverEventsThisWeek
    }
}

/*struct WeekOverView_Previews: PreviewProvider {
    static var previews: some View {
        WeekOverView()
    }
}
 */
