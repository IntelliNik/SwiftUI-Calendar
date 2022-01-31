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
            
            let ekCalEvents = getEventsEKCal40Years(ekCal: ekCal)
            
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
        var save = true
        mEvent.name = ekCalEvent.title
        mEvent.key = UUID()
        
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
            mEvent.repetition = true
            var numberHits = 0
            let rule = ekCalEvent.recurrenceRules![0]
            if rule.recurrenceEnd == nil || rule.recurrenceEnd!.endDate == nil {
                let fetch = ForeverEvent.fetchRequest()
                fetch.predicate = NSPredicate(format: "importedFromUUID == %@", ekCalEvent.eventIdentifier!)
                do{
                    let results = try viewContext.fetch(fetch)
                    numberHits = results.count
                } catch {
                    print("requesting error")
                }
                if numberHits == 0{
                    eventForever.importedFromUUID = mEvent.importedFromUUID
                    eventForever.key = UUID()
                    eventForever.startdate = mEvent.startdate!
                    eventForever.enddate = mEvent.enddate!
                    eventForever.wholeDay = mEvent.wholeDay
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
                    save = false
                }
            }else{
                let fetch2 = Event.fetchRequest()
                fetch2.predicate = NSPredicate(format: "importedFromUUID == %@", ekCalEvent.eventIdentifier!)
                do{
                    let results2 = try viewContext.fetch(fetch2)
                    numberHits = results2.count
                } catch {
                    print("requesting error")
                }
                if numberHits < 2{
                    let repetitionID = UUID()
                    let myCalendar = Calendar.current
                    mEvent.repetitionID = repetitionID
                    mEvent.repetitionEndDate = rule.recurrenceEnd!.endDate
                    mEvent.repetitionInterval = transformFrequencToString(fre: rule.frequency)
                    mEvent.repetitionUntil = "End Date"
                    var currentDate = mEvent.startdate
                    var i = 1
                    while currentDate! < mEvent.repetitionEndDate!{
                        var eventR = Event(context: viewContext)
                        eventR.key = UUID()
                        eventR.importedFromUUID = mEvent.importedFromUUID
                        eventR = CopyMEvent(event1: eventR, event2: mEvent)
                        switch mEvent.repetitionInterval{
                        case "Weekly":
                            eventR.startdate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: mEvent.startdate!)
                            eventR.enddate = myCalendar.date(byAdding: .weekOfYear, value: Int(i), to: mEvent.enddate!)
                        case "Daily":
                            eventR.startdate = myCalendar.date(byAdding: .day, value: Int(i), to: mEvent.startdate!)
                            eventR.enddate = myCalendar.date(byAdding: .day, value: Int(i), to: mEvent.enddate!)
                            
                        case "Monthly":
                            eventR.startdate = myCalendar.date(byAdding: .month, value: i, to: mEvent.startdate!)
                            eventR.enddate = myCalendar.date(byAdding: .month, value: i, to: mEvent.enddate!)
                            
                        case "Yearly":
                            eventR.startdate = myCalendar.date(byAdding: .year, value: Int(i), to: mEvent.startdate!)
                            eventR.enddate = myCalendar.date(byAdding: .year, value: Int(i), to: mEvent.enddate!)
                            
                        default:
                            break
                        }
                        currentDate = eventR.startdate
                        if currentDate! <= mEvent.repetitionEndDate!{
                            mCalendar.addToEvents(eventR)
                            scheduleNotification(event: eventR)
                            i = i + 1
                        } else{
                            viewContext.delete(eventR)
                        }
                    }
                }else{
                    save = false
                }
            }
        }else{
            mEvent.repetition = false
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
        
        if !save {
            viewContext.delete(mEvent)
        }
        
        if foreverEvent {
            viewContext.delete(mEvent)
        }
        
        try! viewContext.save()
    }
    
    func CopyMEvent(event1: Event, event2: Event) -> Event{
        event1.name = event2.name
        event1.wholeDay = event2.wholeDay
        event1.url = event2.url
        event1.notes = event2.notes
        event1.notificationMinutesBefore = event2.notificationMinutesBefore
        
        if event2.location{
            event1.location = true
            event1.latitude = event2.latitude
            event1.longitude = event2.longitude
            event1.latitudeDelta = event2.latitudeDelta
            event1.longitudeDelta = event2.longitudeDelta
        }else{
            event1.location = false
        }
        if event2.notification{
            event1.notification = true
            if(!event2.wholeDay){
                event1.notificationMinutesBefore = event2.notificationMinutesBefore
            } else {
                event1.notificationTimeAtWholeDay = event2.notificationTimeAtWholeDay
            }
        }else{
            event1.notification = false
        }
        event1.repetition = event2.repetition
        if event2.repetition{
            event1.repetitionUntil = event2.repetitionUntil
            event1.repetitionInterval = event2.repetitionInterval
            event1.repetitionID = event2.repetitionID
            event1.repetitionEndDate = event2.repetitionEndDate
        }
        
        return event1
    }
    
    private func getEventsInMCalendar(mCalendar: MCalendar) -> [Event]{
        let fr = Event.fetchRequest()
        let predicate = NSPredicate(format: "calendar == %@ ", mCalendar)
        fr.predicate = predicate
        return try! viewContext.fetch(fr)
    }
    
    private func getForeverEventsInMCalendar(mCalendar: MCalendar) -> [ForeverEvent]{
        let fr = ForeverEvent.fetchRequest()
        let predicate = NSPredicate(format: "calendar == %@ ", mCalendar)
        fr.predicate = predicate
        return try! viewContext.fetch(fr)
    }
    
    private func getEventsInEKCalendar(offsetStartFromToday: Int, offsetEndFromToday: Int, calendar: EKCalendar) -> [EKEvent]{
        let currentCalendar = Calendar.current
        
        var pastComponents = DateComponents()
        pastComponents.year = offsetStartFromToday
        let past = currentCalendar.date(byAdding: pastComponents, to: Date())
        
        var futureComponents = DateComponents()
        futureComponents.year = offsetEndFromToday
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
        
        let mCalForeverEvents = getForeverEventsInMCalendar(mCalendar: mCalendar)
        
        for mEvent in mCalForeverEvents{
            if(mEvent.calendar?.key != mCalendar.key){
                continue
            }
            saveEKCalForeverEventFromMEvent(mEvent: mEvent, ekCalendar: ekCalendar)
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
    
    func transformStringToFrequenc(fre: String) -> EKRecurrenceFrequency{
        switch fre{
        case "Daily":
            return .daily
        case "Weekly":
            return .weekly
        case "Montly":
            return .monthly
        case "Yearly":
            return .yearly
        default:
            return .daily
        }
    }
    
    private func saveEKCalEventFromMEvent(mEvent: Event, ekCalendar: EKCalendar, saveSyncUuidAt: Event? = nil){
        var saveEvent = true
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.calendar = ekCalendar
        
        ekEvent.title = mEvent.name
        
        ekEvent.startDate = mEvent.startdate
        ekEvent.endDate = mEvent.enddate
        ekEvent.isAllDay = mEvent.wholeDay
        
        // repetition
        if mEvent.repetition{
            var startEvent = false
            var results : [Event]
            results = []
            let fetch = Event.fetchRequest()
            fetch.sortDescriptors = [NSSortDescriptor(keyPath: \Event.startdate, ascending: true)]
            fetch.predicate = NSPredicate(format: "repetitionID == %@", mEvent.repetitionID! as CVarArg)
            do{
                results = try viewContext.fetch(fetch)
                if mEvent.key == results[0].key{
                    startEvent = true
                }
            } catch {
                print("requesting error")
            }
            if startEvent{
                let ekrules: EKRecurrenceRule = EKRecurrenceRule.init(recurrenceWith: transformStringToFrequenc(fre: mEvent.repetitionInterval!), interval: 1, end: EKRecurrenceEnd(end: results[(results.count)-1].startdate!))
                ekEvent.recurrenceRules = [ekrules]
            }else{
                saveEvent = false
            }
        }
        
        // location
        if mEvent.location{
            let structuredLocation = EKStructuredLocation()
            let geoLocation = CLLocation(latitude: mEvent.latitude, longitude: mEvent.longitude)
            structuredLocation.geoLocation = geoLocation
            ekEvent.structuredLocation = structuredLocation
        }
        
        // reminder
        if mEvent.notification{
            ekEvent.alarms = [EKAlarm(relativeOffset: TimeInterval((-1)*mEvent.notificationMinutesBefore))]
        }
        
        if let urlString = mEvent.url{
            if let url = URL(string: urlString){
                ekEvent.url = url
            }
        }
        
        ekEvent.notes = mEvent.notes
        if saveEvent{
            try! eventStore.save(ekEvent, span: .futureEvents, commit: true)
        }
        
        if(saveSyncUuidAt != nil){
            saveSyncUuidAt!.importedFromUUID = ekEvent.eventIdentifier
            try! viewContext.save()
        }
    }
    
    private func saveEKCalForeverEventFromMEvent(mEvent: ForeverEvent, ekCalendar: EKCalendar, saveSyncUuidAt: Event? = nil){
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.calendar = ekCalendar
        
        ekEvent.title = mEvent.name
        
        ekEvent.startDate = mEvent.startdate
        ekEvent.endDate = mEvent.enddate
        ekEvent.isAllDay = mEvent.wholeDay
        
        // repetition
        let ekrules: EKRecurrenceRule = EKRecurrenceRule.init(recurrenceWith: transformStringToFrequenc(fre: mEvent.repetitionInterval!), interval: 1, end: nil)
        ekEvent.recurrenceRules = [ekrules]
        
        // location
        if mEvent.location{
            let structuredLocation = EKStructuredLocation()
            let geoLocation = CLLocation(latitude: mEvent.latitude, longitude: mEvent.longitude)
            structuredLocation.geoLocation = geoLocation
            ekEvent.structuredLocation = structuredLocation
        }
        
        // reminder
        if mEvent.notification{
            ekEvent.alarms = [EKAlarm(relativeOffset: TimeInterval((-1)*mEvent.notificationMinutesBefore))]
        }
        
        if let urlString = mEvent.url{
            if let url = URL(string: urlString){
                ekEvent.url = url
            }
        }
        
        ekEvent.notes = mEvent.notes
        try! eventStore.save(ekEvent, span: .futureEvents, commit: true)
        
        if(saveSyncUuidAt != nil){
            saveSyncUuidAt!.importedFromUUID = ekEvent.eventIdentifier
            try! viewContext.save()
        }
    }
    
    private func searchForEventInEKCal(ekCal: EKCalendar, uuidEKEvent: String)->[EKEvent]{
        //search in past
        for iteration in 1...25{
            let fetched = getEventsInEKCalendar(offsetStartFromToday: -(4 * iteration), offsetEndFromToday: -(4 * (iteration-1)), calendar: ekCal)
            if let found = fetched.first(where: {$0.eventIdentifier == uuidEKEvent}) {
                return [found]
            }
        }
        // seach in future
        for iteration in 1...25{
            let fetched = getEventsInEKCalendar(offsetStartFromToday: 4 * (iteration-1), offsetEndFromToday: 4 * iteration, calendar: ekCal)
            if let found = fetched.first(where: {$0.eventIdentifier == uuidEKEvent}) {
                return [found]
            }
        }
        // nothing found...
        return []
    }
    
    private func getEventsEKCal40Years(ekCal: EKCalendar)->[EKEvent]{
        var eventEKCalPast20Years: [EKEvent] = []
        for iteration in 1...5{
            eventEKCalPast20Years.append(contentsOf: getEventsInEKCalendar(offsetStartFromToday: -(4 * iteration), offsetEndFromToday: -(4 * (iteration-1)), calendar: ekCal))
        }
        
        var eventEKCalFuture20Years: [EKEvent] = []
        for iteration in 1...5{
            eventEKCalFuture20Years.append(contentsOf: getEventsInEKCalendar(offsetStartFromToday: 4 * (iteration-1), offsetEndFromToday: 4 * iteration, calendar: ekCal))
        }
        
        // Merge past and future
        return eventEKCalPast20Years + eventEKCalFuture20Years
    }
    
    func synchronizeCalendars(){
        let fr = MCalendar.fetchRequest()
        let predicate = NSPredicate(format: "synchronized == true")
        fr.predicate = predicate
        let syncedCalendars = try! viewContext.fetch(fr)
        
        for mCalendar in syncedCalendars{
            print("SYNC CALENDAR: \(mCalendar.name!)")
            
            let ekCal = eventStore.calendar(withIdentifier: mCalendar.synchronizedWithCalendarIdentifier!)
            
            let eventsEKCal = getEventsEKCal40Years(ekCal: ekCal!)
            
            let eventsMCal = getEventsInMCalendar(mCalendar: mCalendar)
            let uuidsEKCal = eventsEKCal.map{ $0.eventIdentifier }
            let uuidsMCal = eventsMCal.map{ $0.importedFromUUID }
            
            // COMPARING UUIDs OF THE EVENTS TO DERTERMINE WHICH TO IMPORT/EXPORT
            // EXPORT
            var eventsToAddInEkCal: [Event] = []
            for eventMCal in eventsMCal {
                if(uuidsEKCal.contains(eventMCal.importedFromUUID)){
                    // skip the events that are existing in both calendars
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
