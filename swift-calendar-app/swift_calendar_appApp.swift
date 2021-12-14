//
//  swift_calendar_appApp.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 14.12.21.
//

import SwiftUI

@main
struct swift_calendar_appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
