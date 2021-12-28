//
//  CalendarApp.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 19.12.21.
//

import SwiftUI

@main
struct CalendarApp: App {
    var body: some Scene {
        WindowGroup {
            AllEventsView().onAppear(perform: requestPermissions)
        }
    }
}

func requestPermissions(){
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            // TODO: Handle the error here.
        }
        // TODO: Enable or disable features based on the authorization.
    }
}
