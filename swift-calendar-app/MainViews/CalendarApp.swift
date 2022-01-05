//
//  CalendarApp.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 19.12.21.
//

import SwiftUI
import CoreLocation

@main
struct CalendarApp: App {
    @State var saveSucessful = true
    
    @State private var showShowEvent = false
    @State private var showMenu = false
    @State private var showAddEventSheet = false
    @State private var showSearchView = false
    @State private var showAddCalendar = false
    
    @State private var showConfirmationBox = false
    @State private var confirmationBoxText = ""
    
    @State var selectedView: ContainedView = .allEvents
    
    @StateObject private var dataController = DataController()
    
    // TODO: Remove next lines when everything is done
    // @FetchRequest(sortDescriptors: []) var event: FetchedResults<Event>
    // Fetch Request only where we need a request?
    
    var body: some Scene {
        let drag = DragGesture()
            .onEnded { value in
                withAnimation{
                    self.showMenu = false
                }
            }
        WindowGroup {
            ZStack{
                if(showConfirmationBox){
                    ConfirmationBoxView(success: saveSucessful, text: confirmationBoxText)
                    // show on top, even on top of menu
                        .zIndex(2)
                }
                GeometryReader{geometry in
                    if(self.showMenu){
                        // providing a space that is tappable to close the menu
                        Text("")
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color(getAccentColor()))
                            .opacity(0.05)
                            .onTapGesture {
                                withAnimation{
                                    showMenu = false
                                }
                            }
                        MenuView(currentlySelectedView: $selectedView, showAddCalendar: $showAddCalendar, menuOpen: $showMenu)
                            .frame(width: geometry.size.width/2)
                            .transition(.move(edge: .leading))
                            .environment(\.managedObjectContext, dataController.container.viewContext)
                    }
                }
                // show menu on top
                .zIndex(1)
                VStack{
                    NavigationBarView(showMenu: $showMenu, showShowEvent: $showShowEvent, showAddEventSheet: $showAddEventSheet, showSearchView: $showSearchView)
                        .environment(\.managedObjectContext, dataController.container.viewContext)
                    ZStack(alignment: .leading){
                        MainView(containedView: $selectedView)
                            .onAppear(perform: requestPermissions)
                            .sheet(isPresented: $showAddEventSheet, onDismiss: {
                                confirmationBoxText = saveSucessful ? "Event saved" : "Event discarded"
                                showConfirmationBox = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showConfirmationBox = false
                                }
                            }){
                                AddEventView(saveEvent: $saveSucessful)
                                    .interactiveDismissDisabled(true)
                                    .environment(\.managedObjectContext, dataController.container.viewContext)
                            }
                            .environment(\.managedObjectContext, dataController.container.viewContext)
                            .sheet(isPresented: $showAddCalendar, onDismiss: {
                                confirmationBoxText = saveSucessful ? "Calendar saved" : "Calendar discarded"
                                showConfirmationBox = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showConfirmationBox = false
                                }
                            }){
                                AddCalendarView(saveCalendar: $saveSucessful)
                                    .interactiveDismissDisabled(true)
                                    .environment(\.managedObjectContext, dataController.container.viewContext)
                            }
                            .sheet(isPresented: $showSearchView){
                                SearchEventView()
                                    .environment(\.managedObjectContext, dataController.container.viewContext)
                            }
                            .sheet(isPresented: $showShowEvent){
                                ShowEventView(url: "https://apple.com")
                                    .environment(\.managedObjectContext, dataController.container.viewContext)
                            }
                    }
                }
            }
            .gesture(drag)
            .animation(.easeInOut, value: showConfirmationBox)
        }
    }
}


func requestPermissions(){
    // request notification access
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            // TODO: Handle the error here.
        }
        // TODO: Enable or disable features based on the authorization.
    }
    
    // request location access
    let locationManager = CLLocationManager()
    locationManager.requestWhenInUseAuthorization()
}
