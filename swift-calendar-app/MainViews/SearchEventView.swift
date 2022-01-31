//
//  SearchEventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 01.01.22.
//

import SwiftUI

struct SearchEventView: View {    
    @State private var query = ""
    
    @State var saveSucessful = true
    @State var showAddEventSheet = false
    @State var confirmationShown = false
    @State var confirmationForeverEventShown = false
    
    @State var selectedEvent = 0
    @State var selectedEventForever = 0
    @State var saveEvent = 0
    
    @AppStorage("colorScheme") private var colorScheme = "red"

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var events: FetchedResults<Event>
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var foreverEvents: FetchedResults<ForeverEvent>
           
    var body: some View {
        NavigationView {
            if query.isEmpty{
                Text("Searching for events...")
                    .listStyle(.plain)
                    .navigationTitle("Search Events")
            } else {
                List {
                    ForEach((0..<events.count), id: \.self) { index in
                        if (index < events.count) {
                            Button(action: {confirmationShown = true
                                selectedEvent = events.firstIndex {$0 == events[index] }!
                            }){
                                Text("Name: \(events[index].name ?? "") in Calendar: \(events[index].calendar?.name ?? "No Calendar")")
                                    .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                            }
                        }
                    }
                    ForEach((0..<foreverEvents.count), id: \.self) { index in
                        if (index < foreverEvents.count) {
                            Button(action: {confirmationForeverEventShown = true
                                selectedEventForever = foreverEvents.firstIndex {$0 == foreverEvents[index] }!
                            }){
                                Text("Name: \(foreverEvents[index].name ?? "") in Calendar: \(foreverEvents[index].calendar?.name ?? "No Calendar")")
                                    .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                            }
                        }
                    }
                }
            }
            if self.query != "" {
                Button(action: {
                    self.query = ""
                })
                {
                    Image(systemName: "multiply.circle")
                    .foregroundColor(Color.gray)
                }
            }
        }
        .sheet(isPresented: $confirmationShown) {
            ShowEventView(event:events[selectedEvent])
        }
        .sheet(isPresented: $confirmationForeverEventShown) {
            ShowForeverEventView(event:foreverEvents[selectedEventForever])
        }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search events")
        .onChange(of: query) { newValue in
            events.nsPredicate = searchPredicate(query: newValue)
            foreverEvents.nsPredicate = searchPredicateForeverEvents(query: newValue)
         }
        .onAppear {
            //Fix the Cancel button Color
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor(Color(getAccentColorString(from: colorScheme)))], for: .normal)
        }
        
    }
        
    private func searchPredicate(query: String) -> NSPredicate? {
        if query.isEmpty { return nil }
        return NSPredicate(format: "name contains[c] %@", query)
    }
    
    private func searchPredicateForeverEvents(query: String) -> NSPredicate? {
        if query.isEmpty { return nil }
        return NSPredicate(format: "name BEGINSWITH %@", query)
    }
}
