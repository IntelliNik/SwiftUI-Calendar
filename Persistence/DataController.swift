//
//  DataController.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 31.12.21.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    
    let containerURL: URL
    let storeURL: URL
    
    let description: NSPersistentStoreDescription
    let container: NSPersistentContainer
    
    
    init() {
        self.containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.swift.calendar.app")!
        self.storeURL = containerURL.appendingPathComponent("DataModel.sqlite")
        
        self.description = NSPersistentStoreDescription(url: storeURL)
        
        self.container = NSPersistentContainer(name: "swift_calendar_app")
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
