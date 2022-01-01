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
    @State var addEventSuccessful = true
    
    @State private var showShowEvent = false
    @State private var showMenu = false
    @State private var showAddEventSheet = false
    @State private var showSearchBar = false
    @State private var showConfirmationBox = false
    
    @State private var searchBarText = ""
    
    @State var selectedView: ContainedView = .month
    
    @StateObject private var dataController = DataController()
    // TODO: Remove next lines when everything is done
    // @FetchRequest(sortDescriptors: []) var event: FetchedResults<Event>
    // Fetch Request only where we need a request?
    
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
                        ZStack{
                            if(showConfirmationBox){
                                ConfirmationBoxView(success: addEventSuccessful)
                                    // show on top
                                    .zIndex(1)
                            }
                            ZStack(alignment: .leading){
                                MainView(containedView: $selectedView)
                                    .onAppear(perform: requestPermissions)
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarLeading){
                                            Button(action: {self.showMenu.toggle()}) {
                                                Image(systemName: "line.horizontal.3")
                                                    .foregroundColor(Color(getAccentColor()))
                                            }
                                        }
                                        // TODO: for development only
                                        ToolbarItem(placement: .navigationBarTrailing){
                                            Button("Show event"){
                                                showShowEvent.toggle()
                                            }.padding()
                                        }
                                        ToolbarItem(placement: .navigationBarTrailing){
                                            if(showSearchBar){
                                                TextField("Search ...", text: $searchBarText).padding()
                                            }
                                        }
                                        ToolbarItem(placement: .navigationBarTrailing){
                                            Button(action: {self.showSearchBar.toggle()}) {
                                                Image(systemName: "magnifyingglass")
                                                    .foregroundColor(Color(getAccentColor()))
                                            }
                                        }
                                        ToolbarItem(placement: .navigationBarTrailing){
                                            Button(action: {self.showAddEventSheet = true}) {
                                                Image(systemName: "plus")
                                                    .foregroundColor(Color(getAccentColor()))
                                            }
                                        }
                                    }
                                    .sheet(isPresented: $showAddEventSheet, onDismiss: {
                                        showConfirmationBox = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            showConfirmationBox = false
                                        }
                                    }) {
                                        AddEventView(save: $addEventSuccessful)
                                            .interactiveDismissDisabled(true)
                                    }
                                    .environment(\.managedObjectContext, dataController.container.viewContext)
                                    .sheet(isPresented: $showShowEvent){
                                        ShowEventView(url: "https://apple.com")
                                    }
                            }
                        }.animation(.easeIn, value: showConfirmationBox)
                    }
                    if self.showMenu {
                        // providing a space that is tappable to close the menu
                        Text("")
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .background(Color(getAccentColor()))
                            .opacity(0.05)
                            .onTapGesture {
                                showMenu = false
                            }
                        MenuView(currentlySelectedView: $selectedView)
                            .frame(width: geometry.size.width/2)
                    }
                }
            }.gesture(drag)
            .animation(.easeIn, value: showMenu)
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
