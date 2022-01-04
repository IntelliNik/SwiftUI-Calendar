//
//  CalendarEditView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 04.01.22.
//

import SwiftUI

struct EditCalendarView: View {
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ]
    ) var calendars: FetchedResults<MCalendar>
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationView {
            VStack{
                List {
                    ForEach(calendars, id: \.self) { calendar in
                        Text("Calendar Name: \(calendar.name ?? "Anonymous")")
                    }
                    .onDelete ( perform: removeCalendar)
                }
                .toolbar {
                    EditButton()
                }
            }
        }
    }
    
    func removeCalendar(at offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            let calendar = calendars[index]
            moc.delete(calendar)
        }
        try? moc.save()
    }
}

struct CalendarEditView_Previews: PreviewProvider {
    static var previews: some View {
        EditCalendarView()
    }
}
