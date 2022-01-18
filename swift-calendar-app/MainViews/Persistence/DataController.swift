//
//  DataController.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 31.12.21.
//

import Foundation
import CoreData

class DataController: ObservableObject {    
    let container = NSPersistentContainer(name: "store")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
