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
    
    @State var selectedCalendarsEventKitUI: Set<EKCalendar>?
    
    @Environment(\.managedObjectContext) var moc
    
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
                            Text("Export to an iPhone calendar")
                                .font(.headline)
                            Picker("In-app Calendar", selection: $selectedCalendarExport){
                                ForEach(Array(zip(calendarsToSync.indices, calendarsToSync)), id: \.0) { index, calendar in
                                    Text(calendar.name ?? "Unknown Calendar").tag(index)
                                }
                            }
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                            HStack{
                                Button(action: {
                                    if(calendarsToSync.count != 0){
                                        textLoading = "Export to an Apple Calendar..."
                                        withAnimation{
                                            showLoading = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                                            parser.exportMCalendar(calendarsToSync[selectedCalendarExport])
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
                            Text("Import an iPhone calendar")
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
                                .confirmationDialog("Cut the connection for \(stopSyncName) ?", isPresented: $showAlert, titleVisibility: .visible) {
                                    Button("Yes", role: .destructive) {
                                        syncedCalendars[stopSyncIndex!].synchronized = false
                                        try! moc.save()
                                    }
                                    Button("No") { }
                                }
                            if(syncedCalendars.count != 0){
                                List{
                                    ForEach(Array(zip(syncedCalendars.indices, syncedCalendars)), id: \.0) { index, calendar in
                                        HStack{
                                            Button(action: {
                                                stopSyncIndex = index
                                                stopSyncName = syncedCalendars[index].name ?? "Calendar"
                                                if(stopSyncIndex != nil){
                                                    showAlert = true
                                                }
                                            }){
                                                HStack{
                                                    Spacer()
                                                    Text(calendar.synchronizedIsReadonly ? "readonly" : "")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                        .padding()
                                                    Text(calendar.name ?? "Unknown Calendar")
                                                        .tag(index)
                                                }
                                            }
                                        }
                                    }
                                }
                                HStack{
                                    Spacer()
                                    Text("Tap on a calendar inside the list to cut the connection to the iPhone calendar.")
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
                                textLoading = "Transfer in progress..."
                                withAnimation{
                                    showLoading = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                                    withAnimation{
                                        showLoading = false
                                    }
                                    
                                    parser.synchronizeCalendars()
                                    
                                    confirmationText = "Transfer completed"
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
                                    Text("Transfer newly created events")
                                    Spacer()
                                    Image(systemName: "arrow.left.arrow.right")
                                }
                            }
                            Text("This action will import newly created events from your iPhone calendar and export newly created events from you app calendar.")
                                .font(.caption)
                        }
                    }
                }
                .sheet(isPresented: $selectedCalendarImport){
                    CalendarSelector(eventStore: parser.eventStore, calendars: $parser.selectedCalendars, selectedCalendars: $selectedCalendarsEventKitUI)
                }
            }
            .onChange(of: selectedCalendarsEventKitUI){ newValue in
                if(selectedCalendarsEventKitUI != nil){
                    textLoading = "Connecting your selected calendars..."
                    withAnimation{
                        showLoading = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, qos: .background) {
                        parser.selectedCalendars = selectedCalendarsEventKitUI
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
                                // reset selection
                                parser.selectedCalendars = nil
                                selectedCalendarsEventKitUI = nil
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
