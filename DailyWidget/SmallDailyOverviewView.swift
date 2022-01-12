//
//  DailyOverviewView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 10.01.22.
//

import SwiftUI

struct SmallDailyOverviewView: View {
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    var body: some View {
        Text(events[0].name ?? "AAAA")
    }
}

struct SmallDailyOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        SmallDailyOverviewView()
    }
}
