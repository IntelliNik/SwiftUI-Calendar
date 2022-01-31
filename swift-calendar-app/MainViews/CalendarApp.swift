//
//  CalendarApp.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 19.12.21.
//

import SwiftUI
import CoreLocation
import WidgetKit

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
    @State var title = "All Events"
    @StateObject private var dataController = DataController()
    
    @StateObject private var currentTime = CurrentTime()
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
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
                    ConfirmationBoxView(mode: saveSucessful ? .success : .fail, text: confirmationBoxText)
                    // show on top, even on top of menu
                        .zIndex(2)
                }
                GeometryReader{geometry in
                    if(self.showMenu){
                        // providing a space that is tappable to close the menu
                        Text("")
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color(getAccentColorString(from: colorScheme)))
                            .opacity(0.05)
                            .onTapGesture {
                                withAnimation{
                                    showMenu = false
                                }
                            }
                        MenuView(currentlySelectedView: $selectedView, showAddCalendar: $showAddCalendar, menuOpen: $showMenu, title: $title)
                            .frame(width: geometry.size.width/2)
                            .transition(.move(edge: .leading))
                            .environment(\.managedObjectContext, dataController.container.viewContext)
                    }
                }
                // show menu on top
                .zIndex(1)
                VStack{
                    NavigationBarView(showMenu: $showMenu, showShowEvent: $showShowEvent, showAddEventSheet: $showAddEventSheet, showSearchView: $showSearchView, title: title)
                        .environment(\.managedObjectContext, dataController.container.viewContext)
                    ZStack(alignment: .leading){
                        MainView(containedView: $selectedView)
                            .environment(\.managedObjectContext, dataController.container.viewContext)
                        
                            .sheet(isPresented: $showAddEventSheet, onDismiss: {
                                confirmationBoxText = saveSucessful ? "Event saved" : "Event discarded"
                                showConfirmationBox = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    showConfirmationBox = false
                                }
                            }){
                                AddEventView(locationService: LocationService(), saveEvent: $saveSucessful)
                                    .interactiveDismissDisabled(true)
                                    .environment(\.managedObjectContext, dataController.container.viewContext)
                            }
                            .environment(\.managedObjectContext, dataController.container.viewContext)
                            .sheet(isPresented: $showAddCalendar, onDismiss: {
                                confirmationBoxText = saveSucessful ? "Calendar saved" : "Calendar discarded"
                                showConfirmationBox = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    if let appiconcolor =  UserDefaults.standard.string(forKey: "appIcon") {
                        let current_icon = UIApplication.shared.alternateIconName == nil ? "AppIcon-Light" : UIApplication.shared.alternateIconName
                        if ((appiconcolor=="AppIcon-Dark") && !(current_icon == "AppIcon-Dark")) {
                            UIApplication.shared.setAlternateIconName("AppIcon-Dark")
                        }
                        else if ((appiconcolor=="AppIcon-Light") && !(current_icon == "AppIcon-Light")) {
                            UIApplication.shared.setAlternateIconName(nil)
                        }
                    }
                        }
                
            }
            .gesture(drag)
            .animation(.easeInOut, value: showConfirmationBox)
            .environmentObject(currentTime)
            .onChange(of: scenePhase) { newPhase in
                            if newPhase == .active {
                                print("Active")
                                currentTime.activate()
                            } else if newPhase == .inactive {
                                print("Inactive")
                            } else if newPhase == .background {
                                print("Background")
                                WidgetCenter.shared.reloadAllTimelines()
                                currentTime.enterBackground()
                            }
                        }
        }
    }
}

func isAppAlreadyLaunchedOnce() -> Bool {
    let defaults = UserDefaults.standard
    if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
        return true
    } else {
        defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
        return false
    }
}
