//
//  SyncCalendarsView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 18.01.22.
//

import SwiftUI
import EventKit
import EventKitUI

//should probably rather be named import/export calender view
struct SyncCalendarsView: View {
    
    @ObservedObject var parser : EKCal_Parser
    
    @State var selectedCalendarExport = 0
    
    @State var selectedCalendarImport = false
    
    @State var showLoading = false
    
    @State var selectedCalendars: Set<EKCalendar>?
    
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ],
        predicate: NSPredicate(format: "defaultCalendar == %@", "NO")
    ) var calendars: FetchedResults<MCalendar>
    
    var body: some View {
        ZStack{
            if(showLoading){
                ConfirmationBoxView(mode: .loading, text: "Import in progress...")
                    .zIndex(1)
                }
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
                                parser.exportCalendar(calendars[selectedCalendarExport])
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
                        HStack{
                            Button(action: {
                                selectedCalendarImport.toggle()
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
            }
            .sheet(isPresented: $selectedCalendarImport){
                CalendarSelector(eventStore: parser.eventStore, calendars: $parser.selectedCalendars, selectedCalendars: $selectedCalendars)
            }
        }
        .onChange(of: selectedCalendars){ newValue in
            if(selectedCalendars != nil){
            showLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, qos: .background) {
                    parser.selectedCalendars = selectedCalendars
                    self.selectedCalendars = nil
                    showLoading = false
            }
            }
        }
    }
}



/*struct SyncCalendarsView_Previews: PreviewProvider {
 static var previews: some View {
 SyncCalendarsView(parser: <#T##EKCal_Parser#>)
 }
 }*/
