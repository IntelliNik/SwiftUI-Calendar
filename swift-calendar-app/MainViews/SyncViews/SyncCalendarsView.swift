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
    @State var textLoading = ""
    @State var showConfirmation = false
    @State var confirmationText = ""
    
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
                ConfirmationBoxView(mode: .loading, text: textLoading)
                    .zIndex(1)
            }
            if(showConfirmation){
                ConfirmationBoxView(mode: .success, text: confirmationText)
                    .zIndex(1)
            }
            NavigationView{
                Form{
                    Section{
                        Picker("", selection: $selectedCalendarExport){
                            ForEach(Array(zip(calendars.indices, calendars)), id: \.0) { index, calendar in
                                Text(calendar.name ?? "Unknown Calendar").tag(index)
                            }
                        }
                        HStack{
                            Button(action: {
                                textLoading = "Export in progress..."
                                withAnimation{
                                    showLoading = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                                    parser.exportCalendar(calendars[selectedCalendarExport])
                                    withAnimation{
                                        showLoading = false
                                    }
                                    confirmationText = "Export successful"
                                    withAnimation{
                                        showConfirmation = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                                        withAnimation{
                                            showConfirmation = false
                                        }
                                    }
                                }
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
                                    Text("Import Calendars")
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
                textLoading = "Import in progress..."
                withAnimation{
                    showLoading = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                    parser.selectedCalendars = selectedCalendars
                    self.selectedCalendars = nil
                    withAnimation{
                        showLoading = false
                    }
                    confirmationText = "Import successful"
                    withAnimation{
                        showConfirmation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                        withAnimation{
                            showConfirmation = false
                        }
                    }
                }
            }
        }
    }
}
