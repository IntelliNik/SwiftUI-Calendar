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
    @Published var accessGranted = false
    private var calendarSubscribers: Set<AnyCancellable> = []
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext){
        self.viewContext = viewContext
        
        //accessGranted = requestAccess()
        
        $selectedCalendars.sink( receiveValue: { calendars in
            if calendars != nil {
                self.parseAndSaveCalendars(calendars)
            }
            
        }).store(in: &calendarSubscribers)
        
    }
    
    private func parseAndSaveCalendars(_ calendars: Set<EKCalendar>?) {
        //read EKCalendars array and make it an MCalendar
        for ekCal in calendars! {
            
            let mCalendar = MCalendar(context: viewContext)
            mCalendar.key = UUID()
            mCalendar.name = ekCal.title
            mCalendar.color = getRandomCalendarColor()
            mCalendar.defaultCalendar = false
            mCalendar.imported = true
            
            try! viewContext.save()
            
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
                mEvent.enddate = ekCalEvent.endDate
                
                //location
                mEvent.location = ekCalEvent.structuredLocation != nil
                // TODO: convert location somehow
                
                mEvent.notes = ekCalEvent.notes
                
                //notifications => notificationDates
                mEvent.notification = ekCalEvent.hasAlarms
                if(ekCalEvent.hasAlarms){
                    var notificationDates: [Date] = []
                    ekCalEvent.alarms?.forEach{ alarm in
                        if let date = alarm.absoluteDate{
                            notificationDates.append(date)
                        }
                    }
                    mEvent.notificationDates = notificationDates
                }
                
                // repetition
                // TODO: convert repetition somehow
                mEvent.repetition = ekCalEvent.isDetached
                
                mEvent.url = ekCalEvent.url?.absoluteString
                
                mEvent.wholeDay = ekCalEvent.isAllDay
                
                mCalendar.addToEvents(mEvent)
                
                try! viewContext.save()
            }
        }
    }
    
    func exportCalendar(_ mCalendar: MCalendar){
        let ekCalendar = EKCalendar(for: .event, eventStore: eventStore)
        ekCalendar.title = mCalendar.name ?? "Calendar"
        ekCalendar.cgColor = UIColor.random.cgColor
        
        ekCalendar.source = eventStore.sources.first(where: { $0.sourceType == .local })
        try! eventStore.saveCalendar(ekCalendar, commit: true)
        
        let predicate = NSPredicate(format: "calendar == %@ ", mCalendar)
        let fr: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Event")
        
        let events = try! viewContext.fetch(fr) as! [Event]
        
        for mEvent in events{
            if(mEvent.calendar?.key != mCalendar.key){
                continue
            }
            let ekEvent = EKEvent(eventStore: eventStore)
            ekEvent.calendar = ekCalendar
            
            ekEvent.title = mEvent.name
            
            ekEvent.startDate = mEvent.startdate
            ekEvent.endDate = mEvent.enddate
            ekEvent.isAllDay = mEvent.wholeDay
            
            // repetition
            
            // location
            
            // reminder
            
            if let urlString = mEvent.url{
                if let url = URL(string: urlString){
                    ekEvent.url = url
                }
            }
            
            ekEvent.notes = mEvent.notes
            
            // TODO: decide how to set span here
            try! eventStore.save(ekEvent, span: .futureEvents, commit: true)
        }
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
    
    func requestAccess(){
        let _ = eventStore.requestAccess(to: .event){_ , _ in
            DispatchQueue.main.async {
                self.accessGranted = self.checkAccess()
            }
        }
    }
    
    func checkAccess() -> Bool {
        switch EKEventStore.authorizationStatus(for: .event){
        case .authorized:
            return true
        case .notDetermined:
            return false
        case .restricted:
            return false
        case .denied:
            return false
        @unknown default:
            return false
        }
    }
}
