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
    
    @State var showAlert = false
    @State var stopSyncName = ""
    @State var stopSyncIndex: Int?
    
    @State var selectedCalendars: Set<EKCalendar>?
    
    @Environment(\.managedObjectContext) var moc
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ],
        predicate: NSPredicate(format: "synchronized == false")
    ) var calendarsToSync: FetchedResults<MCalendar>
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ],
        predicate: NSPredicate(format: "synchronized == true")
    ) var syncedCalendars: FetchedResults<MCalendar>
    
    var body: some View {
        if(parser.accessGranted){
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
                            Text("Connect to an iPhone calendar")
                                .font(.headline)
                            Picker("In-app Calendar", selection: $selectedCalendarExport){
                                ForEach(Array(zip(calendarsToSync.indices, calendarsToSync)), id: \.0) { index, calendar in
                                    Text(calendar.name ?? "Unknown Calendar").tag(index)
                                }
                            }
                            HStack{
                                Button(action: {
                                    if(calendarsToSync.count != 0){
                                        textLoading = "Export to an Apple Calendar..."
                                        withAnimation{
                                            showLoading = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                                            parser.exportCalendar(calendarsToSync[selectedCalendarExport])
                                            withAnimation{
                                                showLoading = false
                                            }
                                            confirmationText = "Connected"
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
                                }) {
                                    HStack{
                                        Text("Connect")
                                        Spacer()
                                        Image(systemName: "square.and.arrow.up")
                                            .imageScale(.large)
                                    }
                                }
                            }
                        }
                        Section{
                            Text("Connect an iPhone calendar")
                                .font(.headline)
                            HStack{
                                Button(action: {
                                    selectedCalendarImport.toggle()
                                }) {
                                    HStack{
                                        Text("Connect")
                                        Spacer()
                                        Image(systemName: "square.and.arrow.down")
                                            .imageScale(.large)
                                    }
                                }
                            }
                        }
                        Section{
                            Text("Currently connected Calendars")
                                .font(.headline)
                                .confirmationDialog("Stop synchronizing Calendar \(stopSyncName) ?", isPresented: $showAlert, titleVisibility: .visible) {
                                    Button("Yes", role: .destructive) {
                                        syncedCalendars[stopSyncIndex!].synchronized = false
                                        try! moc.save()
                                    }
                                    Button("No") { }
                                }
                            if(syncedCalendars.count != 0){
                                List{
                                    ForEach(Array(zip(syncedCalendars.indices, syncedCalendars)), id: \.0) { index, calendar in
                                        Button(action: {
                                            stopSyncIndex = index
                                            stopSyncName = syncedCalendars[index].name ?? "Unkown"
                                            if(stopSyncIndex != nil){
                                                showAlert = true
                                            }
                                        }){
                                            HStack{
                                                Spacer()
                                                Text(calendar.name ?? "Unknown Calendar").tag(index)
                                            }
                                        }
                                    }
                                }
                                HStack{
                                    Spacer()
                                    Text("Tap a calendar to stop synchronizing")
                                        .font(.caption)
                                }
                            } else{
                                HStack{
                                    Spacer()
                                    Text("None")
                                        .font(.caption)
                                }
                            }
                        }
                        Section{
                            Button(action: {
                                textLoading = "Sync in progress..."
                                withAnimation{
                                    showLoading = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                                    withAnimation{
                                        showLoading = false
                                    }
                                    
                                    // TODO: SYNCHRONIZE HERE
                                    
                                    confirmationText = "Sync completed"
                                    withAnimation{
                                        showConfirmation = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                                        withAnimation{
                                            showConfirmation = false
                                        }
                                    }
                                    
                                }
                            }){
                                HStack{
                                    Text("Synchronize Calendars now")
                                        .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                                    Spacer()
                                    Image(systemName: "arrow.triangle.2.circlepath")
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
                    textLoading = "Connecting your selected calendars..."
                    withAnimation{
                        showLoading = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                        parser.selectedCalendars = selectedCalendars
                        self.selectedCalendars = nil
                        withAnimation{
                            showLoading = false
                        }
                        confirmationText = "Connected"
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
        } else{
            VStack{
                Image(systemName: "lock.fill")
                    .font(.system(size: 128))
                    .foregroundColor(.gray)
                    .padding()
                Text("Please allow access to your Calenders to use this feature.")
                Spacer()
            }
            .onAppear{
                parser.requestAccess()
            }
        }
    }
}
