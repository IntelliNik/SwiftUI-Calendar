//
//  DataController.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 31.12.21.
//

import Foundation
import CoreData

// DataController for CoreData
// An instance of this class is created at the start of the app
// This instance can be accessed from every view via environment to make changes to the data core

class DataController: ObservableObject {
    
    let containerURL: URL
    let storeURL: URL
    
    let description: NSPersistentStoreDescription
    let container: NSPersistentContainer
    
    
    init() {
        self.containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.swift.calendar.app")!
        self.storeURL = containerURL.appendingPathComponent("store.sqlite")
        
        self.description = NSPersistentStoreDescription(url: storeURL)
        
        self.container = NSPersistentContainer(name: "store")
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
