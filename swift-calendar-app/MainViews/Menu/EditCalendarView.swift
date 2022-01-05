//
//  CalendarEditView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 04.01.22.
//

import SwiftUI

struct EditCalendarView: View {
    @State var saveSucessful = true
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ]
    ) var calendars: FetchedResults<MCalendar>
    
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationView {
            List {
                ForEach((0..<calendars.count), id: \.self) { index in
                    if (index < calendars.count) {
                        NavigationLink(
                            destination: ModifyCalendar(mcalendar: calendars[index], saveCalendar: $saveSucessful)
                        ) {
                            Text("Calendar Name: \(calendars[index].name ?? "")")
                        }
                    }
                }
                .onDelete ( perform: removeCalendar)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: AddCalendarView(saveCalendar: $saveSucessful)
                    ) {
                        Text("+")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .navigationTitle("Edit Calendars")
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
