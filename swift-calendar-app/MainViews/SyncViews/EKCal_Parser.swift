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
    
    @FetchRequest(
        entity: ForeverEvent.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ForeverEvent.startdate, ascending: true),
        ]
    ) var allForeverEvents: FetchedResults<ForeverEvent>
    
    init(viewContext: NSManagedObjectContext){
        self.viewContext = viewContext
        
        //accessGranted = requestAccess()
        
        $selectedCalendars.sink( receiveValue: { calendars in
            if calendars != nil {
                self.importEKCalendar(calendars)
            }
            
        }).store(in: &calendarSubscribers)
        
    }
    
    private func importEKCalendar(_ calendars: Set<EKCalendar>?) {
        //read EKCalendars array and make it an MCalendar
        for ekCal in calendars! {
            
            let mCalendar = MCalendar(context: viewContext)
            mCalendar.key = UUID()
            mCalendar.name = ekCal.title
            mCalendar.color = getRandomCalendarColor()
            mCalendar.defaultCalendar = false
            mCalendar.imported = true
            mCalendar.synchronizedIsReadonly = ekCal.isImmutable
            
            mCalendar.synchronized = true
            mCalendar.synchronizedWithCalendarIdentifier = ekCal.calendarIdentifier
            
            try! viewContext.save()
            
            let ekCalEvents = getEventsInEKCalendar(yearsPast: 2, yearsFuture: 2, calendar: ekCal)
            
            // Create Events, store them in the newly created calendar
            ekCalEvents.forEach{ ekCalEvent in
                saveEventinMCalendar(ekCalEvent: ekCalEvent, mCalendar: mCalendar)
            }
        }
    }
    
    private func saveEventinMCalendar(ekCalEvent: EKEvent, mCalendar: MCalendar, saveSyncUuidAt: Bool? = nil){
        let mEvent = Event(context: viewContext)
        let eventForever = ForeverEvent(context: viewContext)
        var foreverEvent = false
        mEvent.name = ekCalEvent.title
        
        mEvent.importedFromUUID = ekCalEvent.eventIdentifier
        
        mEvent.startdate = ekCalEvent.startDate
        mEvent.enddate = ekCalEvent.endDate
        
        //location
        //mEvent.location = ekCalEvent.structuredLocation != nil
        if (ekCalEvent.structuredLocation != nil && ekCalEvent.structuredLocation?.geoLocation != nil){
            mEvent.location = true
            mEvent.longitude = (ekCalEvent.structuredLocation?.geoLocation?.coordinate.longitude)!
            mEvent.latitude = (ekCalEvent.structuredLocation?.geoLocation?.coordinate.latitude)!
            mEvent.latitudeDelta = 0.01
            mEvent.longitudeDelta = 0.01
        }else{
            mEvent.location = false
        }
        
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
        
        mEvent.url = ekCalEvent.url?.absoluteString
        
        mEvent.wholeDay = ekCalEvent.isAllDay
        
        if ekCalEvent.hasRecurrenceRules{
            var numberHits = 0
            let fetch = ForeverEvent.fetchRequest()
            fetch.predicate = NSPredicate(format: "importedFromUUID == %@", ekCalEvent.eventIdentifier!)
            do{
                let results = try viewContext.fetch(fetch)
                numberHits = results.count
                print(numberHits)
            } catch {
                print("requesting error")
            }
            //allForeverEvents.nsPredicate = NSPredicate(format: "importedFromUUID == %@", ekCalEvent.eventIdentifier ?? "")
            if numberHits == 0 {
                let rule = ekCalEvent.recurrenceRules![0]
                if rule.recurrenceEnd == nil{
                    eventForever.key = UUID()
                    eventForever.startdate = mEvent.startdate!
                    eventForever.enddate = mEvent.enddate!
                    eventForever.name = mEvent.name
                    eventForever.url = mEvent.url
                    eventForever.notes = mEvent.notes
                    
                    if mEvent.location{
                        eventForever.location = true
                        eventForever.latitude = mEvent.latitude
                        eventForever.longitude = mEvent.longitude
                        eventForever.latitudeDelta = mEvent.latitudeDelta
                        eventForever.longitudeDelta = mEvent.longitudeDelta
                    }else{
                        eventForever.location = false
                    }
                    if mEvent.notification{
                        eventForever.notification = true
                        if(!mEvent.wholeDay){
                            eventForever.notificationMinutesBefore = mEvent.notificationMinutesBefore
                        } else {
                            eventForever.notificationTimeAtWholeDay = mEvent.notificationTimeAtWholeDay
                        }
                    }else{
                        eventForever.notification = false
                    }
                    
                    eventForever.repetitionInterval = transformFrequencToString(fre: rule.frequency)
                    
                    mCalendar.addToForeverEvents(eventForever)
                    viewContext.delete(mEvent)
                    foreverEvent = true
                }else{
                    
                }
            }
        }
        
        if !foreverEvent{
            mCalendar.addToEvents(mEvent)
        }
        
        if(saveSyncUuidAt == true){
            if !foreverEvent{
                mEvent.importedFromUUID = ekCalEvent.eventIdentifier
            }else{
                eventForever.importedFromUUID = ekCalEvent.eventIdentifier
            }
        }
        
        try! viewContext.save()
    }
    
    private func getEventsInMCalendar(mCalendar: MCalendar) -> [Event]{
        let fr = Event.fetchRequest()
        let predicate = NSPredicate(format: "calendar == %@ ", mCalendar)
        fr.predicate = predicate
        return try! viewContext.fetch(fr)
    }
    
    
    private func getEventsInEKCalendar(yearsPast: Int, yearsFuture: Int, calendar: EKCalendar) -> [EKEvent]{
        let currentCalendar = Calendar.current
        
        var pastComponents = DateComponents()
        pastComponents.year = -yearsPast
        let past = currentCalendar.date(byAdding: pastComponents, to: Date())
        
        var futureComponents = DateComponents()
        futureComponents.year = yearsFuture
        let future = currentCalendar.date(byAdding: futureComponents, to: Date())
        
        var predicate: NSPredicate? = nil
        if let p = past, let f = future {
            predicate = eventStore.predicateForEvents(withStart: p, end: f, calendars: [calendar])
        }
        
        return eventStore.events(matching: predicate!)
    }
    
    func exportMCalendar(_ mCalendar: MCalendar){
        let ekCalendar = EKCalendar(for: .event, eventStore: eventStore)
        
        mCalendar.synchronized = true
        mCalendar.synchronizedWithCalendarIdentifier = ekCalendar.calendarIdentifier
        
        try! viewContext.save()
        
        ekCalendar.title = mCalendar.name ?? "Calendar"
        ekCalendar.cgColor = UIColor.random.cgColor
        
        ekCalendar.source = eventStore.sources.first(where: { $0.sourceType == .local })
        try! eventStore.saveCalendar(ekCalendar, commit: true)
    
        let mCalEvents = getEventsInMCalendar(mCalendar: mCalendar)
        
        for mEvent in mCalEvents{
            if(mEvent.calendar?.key != mCalendar.key){
                continue
            }
            saveEKCalEventFromMEvent(mEvent: mEvent, ekCalendar: ekCalendar)
        }
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
    
    func transformFrequencToString(fre: EKRecurrenceFrequency) -> String {
        switch fre{
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        default:
            return "Daily"
        }
    }
    
    private func saveEKCalEventFromMEvent(mEvent: Event, ekCalendar: EKCalendar, saveSyncUuidAt: Event? = nil){
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
        // TODO: SHIT, SOME CALENDARS ARE READONLY, E.G. THE BIRTYDAY ONE -> HANDLE THIS
        try! eventStore.save(ekEvent, span: .futureEvents, commit: true)
        
        if(saveSyncUuidAt != nil){
            saveSyncUuidAt!.importedFromUUID = ekEvent.eventIdentifier
            try! viewContext.save()
        }
    }
    
    func synchronizeCalendars(){
        let fr = MCalendar.fetchRequest()
        let predicate = NSPredicate(format: "synchronized == true")
        fr.predicate = predicate
        let syncedCalendars = try! viewContext.fetch(fr)
        
        for mCalendar in syncedCalendars{
            print("SYNC CALENDAR: \(mCalendar.name!)")
            
            let ekCal = eventStore.calendar(withIdentifier: mCalendar.synchronizedWithCalendarIdentifier!)
            
            let eventsEKCal = getEventsInEKCalendar(yearsPast: 2, yearsFuture: 2, calendar: ekCal!)
            let eventsMCal = getEventsInMCalendar(mCalendar: mCalendar)
            let uuidsEKCal = eventsEKCal.map{ $0.eventIdentifier }
            let uuidsMCal = eventsMCal.map{ $0.importedFromUUID }
            
            // COMPARING UUIDs OF THE EVENTS TO DERTERMINE WHICH TO IMPORT/EXPORT
            // EXPORT
            var eventsToAddInEkCal: [Event] = []
            for eventMCal in eventsMCal {
                if(uuidsEKCal.contains(eventMCal.importedFromUUID)){
                    // skip existing events
                    continue
                }else{
                    // collect events to add
                    eventsToAddInEkCal.append(eventMCal)
                }
            }
            print("TO EXPORT", eventsToAddInEkCal.map{$0.name})
            
            // Export new events to EKCal and save syncUUID to remember the event synced with
            if(!ekCal!.isImmutable){
                for mEvent in eventsToAddInEkCal{
                    saveEKCalEventFromMEvent(mEvent: mEvent, ekCalendar: ekCal!, saveSyncUuidAt: mEvent)
                }
            }else{
                print("WARNING! Calendar \(ekCal!.title) is readonly, continuing without writing to that calendar.")
            }
            
            // IMPORT
            var eventsToAddInMCal: [EKEvent] = []
            for eventEkCal in eventsEKCal {
                if(uuidsMCal.contains(eventEkCal.eventIdentifier)){
                    // skip existing events
                    continue
                }else{
                    // collect events to add
                    eventsToAddInMCal.append(eventEkCal)
                }
            }
            print("TO IMPORT", eventsToAddInMCal.map{$0.title})
            
            // Import new events to MKCal and save syncUUID to remember the event synced with
            for ekCalEvent in eventsToAddInMCal{
                //saveEKCalEventFromMEvent(mEvent: mEvent, ekCalendar: ekCal!, saveSyncUuidAt: mEvent)
                saveEventinMCalendar(ekCalEvent: ekCalEvent, mCalendar: mCalendar, saveSyncUuidAt: true)
            }
            
            
            print("Sanity check: \(ekCal!.title) EkCal:\(eventsEKCal.count) MCal:\(eventsMCal.count)")
        }
    }
}
