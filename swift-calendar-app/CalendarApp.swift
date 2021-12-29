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
    @State private var showMenu = false
    @State private var showAddEventSheet = false
    @State private var showSearchBar = false
    @State private var searchBarText = ""
    
    @State var selectedView: ContainedView = .month
    
    enum Modes{
        case day
        case week
        case month
        case year
        case allEvents
    }
    
    var body: some Scene {
        let drag = DragGesture()
            .onEnded { value in
                self.showMenu = false
            }
        WindowGroup {
            ZStack{
                GeometryReader{geometry in
                    NavigationView{
                        VStack{
                            if(showSearchBar){
                                TextField("Search ...", text: $searchBarText).padding()
                            }
                            ZStack(alignment: .leading){
                                MainView(containedView: $selectedView)
                                    .onAppear(perform: requestPermissions)
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarLeading){
                                            Button(action: {self.showMenu.toggle()}) {
                                                Image(systemName: "line.horizontal.3")
                                            }
                                        }
                                        ToolbarItem(placement: .navigationBarTrailing){
                                            Button(action: {self.showSearchBar.toggle()}) {
                                                Image(systemName: "magnifyingglass")
                                            }
                                        }
                                        ToolbarItem(placement: .navigationBarTrailing){
                                            Button(action: {self.showAddEventSheet = true}) {
                                                Image(systemName: "plus")
                                            }
                                        }
                                    }
                                    .sheet(isPresented: $showAddEventSheet) {
                                        AddEventView()
                                            .interactiveDismissDisabled(true)
                                    }
                            }
                        }
                    }
                    if self.showMenu {
                        // providing a space that is tappable to close the menu
                        Text("")
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color("AccentColor"))
                            .opacity(0.05)
                            .onTapGesture {
                                showMenu = false
                            }
                        MenuView(currentlySelectedView: $selectedView)
                            .frame(width: geometry.size.width/2)
                    }
                }
            }.gesture(drag)
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
