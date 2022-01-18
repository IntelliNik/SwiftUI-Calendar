//
//  SyncCalendarsView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 18.01.22.
//

import SwiftUI

struct SyncCalendarsView: View {
    
    @State var selectedCalendarImport = 0
    @State var selectedCalendarExport = 0
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ],
        predicate: NSPredicate(format: "defaultCalendar == %@", "NO")
    ) var calendars: FetchedResults<MCalendar>
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    Text("Choose a calendar to export to an Apple Calendar: ")
                    Picker("", selection: $selectedCalendarExport){
                        ForEach(Array(zip(calendars.indices, calendars)), id: \.0) { index, calendar in
                            Text(calendar.name ?? "Unknown Calendar").tag(index)
                        }
                    }
                    HStack{
                        Button(action: {
                            // do stuff here
                        }) {
                            HStack{
                                Text("Export Calendar")
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
                Section{
                    Text("Choose a calendar to import from an Apple Calendar: ")
                    Picker("", selection: $selectedCalendarImport){
                        // display the users calendars here
                    }
                    HStack{
                        Button(action: {
                            // do stuff here
                        }) {
                            HStack{
                                Text("Import Calendar")
                                Spacer()
                                Image(systemName: "square.and.arrow.down")
                                    .imageScale(.large)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Synchronize calendars")
        }
    }
}

struct SyncCalendarsView_Previews: PreviewProvider {
    static var previews: some View {
        SyncCalendarsView()
    }
}
