//
//  TestDataCore.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 01.01.22.
//

//TODO: Remove the complete file. Only for tests

import SwiftUI

struct TestDataCore: View {
    
    @Environment(\.managedObjectContext) var moc
    
    //TODO: Remove next comment lines when everything is done
    //Need the next line in every structure where we make
    //a data base request.
    //@FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "name BEGINSWITH %@", "Hallo")) var events: FetchedResults<Event>
    //@FetchRequest(sortDescriptors: []) var events: FetchedResults<Event>
    /*@FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.name, ascending: true),
        ],
        predicate:
            NSPredicate(format: "name BEGINSWITH %@", "Opa")
    ) var events: FetchedResults<Event>  */
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.name, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ]
    ) var calendars: FetchedResults<MCalendar>
    
    
    var body: some View {
        NavigationView {
            VStack{
            List {
                ForEach(events, id: \.self) { event in
                    Text("Name: \(event.name ?? "") in Calendar: \(event.calendar?.name ?? "No Calendar")")
                }
                .onDelete ( perform: removeEvent)
            }
            .toolbar {
                EditButton()
            }
            
            List {
                ForEach(calendars, id: \.self) { calendar in
                    Text("Calendar Name: \(calendar.name ?? "Anonymous")")
                }
                .onDelete ( perform: removeCalendar)
            }
            .toolbar {
                EditButton()
            }
            
            Button(action: addCalendar){
                Text("Add Calendar")
            }
            }
        }
        
        // The next lines are somehow not working to delete an event.
        /*VStack {
            List {
                ForEach(events, id: \.self) { event in
                    Text("Creator: \(event.name ?? "Anonymous")")
                }
                .onDelete(perform: removeEvent)
            }
            .navigationBarTitle("Delete")
            .navigationBarItems(leading:EditButton())
            //List(events) { event in
            //    Text(event.name ?? "Unknown")
            //}
        }*/
    }
    
    func removeEvent(at offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            let event = events[index]
            moc.delete(event)
        }
        try? moc.save()
    }
    
    func removeCalendar(at offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            let calendar = calendars[index]
            moc.delete(calendar)
        }
        try? moc.save()
    }
    
    func addCalendar (){
        if calendars.isEmpty {
            let calendar = MCalendar(context: moc)
            calendar.key = UUID()
            calendar.name = "Calendar1"
            calendar.color = "Yellow"
            
            try? moc.save()
        }
        
        /*let calendar = MCalendar(context: moc)
        calendar.name = "Calendar2"
        calendar.color = ".green"
        
        try? moc.save()*/
    }
}

// TODO: Remove this structure
struct ExampleView: View {
    @State var fruits = ["🍌", "🍏", "🍑"]

    var body: some View {
        NavigationView {
            List {
                ForEach(fruits, id: \.self) { fruit in
                    Text(fruit)
                }
                .onDelete { offsets in
                    fruits.remove(atOffsets: offsets)
                }
            }
            .toolbar {
                EditButton()
            }
        }
    }
}

struct TestDataCore_Previews: PreviewProvider {
    static var previews: some View {
        TestDataCore()
    }
}
