//
//  EKCal_Parser.swift
//  swift-calendar-app
//
//  Created by Andreas RF Dymek on 21.01.22.
//

import Foundation
import EventKit
import EventKitUI
import Combine
import SwiftUI
import CoreData

class EKCal_Parser: ObservableObject
{
    
    //instace that will be provided to sync view
    //static let instance = EKCal_Parser()
    
    //the eventstore to access system calendars
    let eventStore = EKEventStore()
    //the selectedCalendars to import
    @Published var selectedCalendars: Set<EKCalendar>?
    private var calendarSubscribers: Set<AnyCancellable> = []
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext){
        self.viewContext = viewContext
        
        let _ = requestAccess()
        
        $selectedCalendars.sink( receiveValue: { calendars in
            if calendars != nil {
                self.parseAndSaveCalendars(calendars)
            }
            
        }).store(in: &calendarSubscribers)
        
    }
    
    private func parseAndSaveCalendars(_ calendars: Set<EKCalendar>?) {        //read EKCalendars array and make it an MCalendar
        for ekCal in calendars! {
            
            let mCalendar = MCalendar(context: viewContext)
            mCalendar.key = UUID()
            mCalendar.name = ekCal.title
            //TODO: what the actual fuck? who uses strings for colors?????
            mCalendar.color = "Red"
            mCalendar.defaultCalendar = false
            mCalendar.imported = true
            
            try? viewContext.save()
            
            let currentCalendar = Calendar.current
            
            // Get the events of the calendar
            // TODO: max time span of 4 years here
            var pastComponents = DateComponents()
            pastComponents.year = -2
            let past = currentCalendar.date(byAdding: pastComponents, to: Date())

            var futureComponents = DateComponents()
            futureComponents.year = 2
            let future = currentCalendar.date(byAdding: futureComponents, to: Date())

            var predicate: NSPredicate? = nil
            if let p = past, let f = future {
                predicate = eventStore.predicateForEvents(withStart: p, end: f, calendars: [ekCal])
            }
            
            let ekCalEvents = eventStore.events(matching: predicate!)
            
            // Create Events, store them in the newly created calendar
            ekCalEvents.forEach{ ekCalEvent in
                let mEvent = Event(context: viewContext)
                mEvent.name = ekCalEvent.title
                
                mEvent.startdate = ekCalEvent.startDate
                mEvent.startdate = ekCalEvent.endDate
                
                //location
                
                mEvent.notes = ekCalEvent.notes
                
                //notification
                
                //repetition
                mEvent.repetition = ekCalEvent.isDetached
                
                mEvent.url = ekCalEvent.url?.absoluteString
                
                mEvent.wholeDay = ekCalEvent.isAllDay
                
                mCalendar.addToEvents(mEvent)
                
                try? viewContext.save()
            }
            
            //TODO: selectedCalendars disappear after restart
            //TODO: save it in user defaults, so it is persistent after restart
            //TODO: check for doubles
        }
    }
    
    func exportCalendar(_ mCalendar: MCalendar){
        let ekCalendar = EKCalendar(for: .event, eventStore: eventStore)
        ekCalendar.title = mCalendar.name ?? "Calendar"
        ekCalendar.cgColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 0.5, 0.5, 1.0])
    }
    
    private func caseInternalChange_syncImported(){
        //sync means take all selected calendars
        //alle mcalendars die attribut imported auf true haben
        //guck events durch pro calendar
    }
    
    private func caseExternalChange_syncImported(){
        //sync means take all selected calendars
        //alle mcalendars die attribut imported auf true haben
        //guck events durch pro calendar
    }
    
    private func syncExported(){
        //TODO: Put in fetch request
        //TODO: get access to our calendar list
        //alle mcalendars die attribut imported auf false haben
        //guck events durch pro calendar
    }
    
    
    
    
    private func saveSelectedCalendars(_ calendars: Set<EKCalendar>?) {
        if let identifiers = calendars?.compactMap({ $0.calendarIdentifier }) {
            UserDefaults.standard.set(identifiers, forKey: "CalendarIdentifiers")
        }
    }
    

    func requestAccess() -> Bool {
        //TODO: What if denied?
        if (EKEventStore.authorizationStatus(for: .event) == EKAuthorizationStatus.notDetermined)
        {
            var r = false;
            eventStore.requestAccess(to: .event) { granted, error in
                if granted {
                    r = true
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            return r
        }
        
        else {
            return true
        }
    }
    
}