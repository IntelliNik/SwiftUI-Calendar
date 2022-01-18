//
//  NotificationManager.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 17.01.22.
//

import Foundation
import UserNotifications

let center = UNUserNotificationCenter.current()

/*func requestNotificationPermissions() {
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            // TODO: Handle the error here.
            //TODO: Find out what to do when the user doesn't want notifications?
        }
        // TODO: Enable or disable features based on the authorization.
        
    }
}*/ //Should this be here or in AddEventView?

//Called after an event is saved
func scheduleNotification(event: Event) {

    //Case 1: Only One Notification Necessary (No Repetitions or repetitionUntil forever
    if !event.repetition {
        createSingleNotification(event: event)
    }
    else if event.repetitionUntil == "Forever" {
        createSingleNotification(event: event)
    }
    else if event.repetitionUntil == "Repetitions" {    //Case 1: x number of repeats -> create x different notifications, calculate times manually
        createNotificationRepetitions(amount: Int(event.repetitionAmount), event: event)
    }
    else if event.repetitionUntil == "End Date" { //Repeat until enddate -> create y different notifications, calculate times manually
        createNotificationRepetitions(enddate: event.enddate!, event: event)
    }
    else {
        //TODO: Something went wrong. whoops
    }
    
    }

//Private helper function to create only one notification
private func createSingleNotification(event: Event) { //just a boring event with one notification, no repetitions or infinite repetitions
    let new_notification = UNMutableNotificationContent()
    new_notification.title = "Calendar Event Coming Up"
    
    if let name = event.name {
        new_notification.subtitle = name
    } else {
        new_notification.subtitle = ""
    }
    
    new_notification.sound = .default
    new_notification.badge = 1
    
    var notification_datecomp = DateComponents()
    
    //First, load the date of the event in the datecomponents.
    let date = event.startdate! //TODO: Consider if there are any cases where this might lead to a crash.
    //now offset the notificationMinutesBefore
    //TODO: Make this work for a wholeDay (needs fixes in AddEventSwift, as .notificationMinutesBefore is set to 0 when wholeDay is true!)
    let calendar = Calendar.current
    var modifiedDate : Date
    
    if event.wholeDay {
        modifiedDate = Calendar.current.date(byAdding: .day, value: -Int(event.notificationMinutesBefore / 1440), to: date)! //convert to date first
    } else {
        modifiedDate = Calendar.current.date(byAdding: .minute, value: -Int(event.notificationMinutesBefore), to: date)!
    }

    notification_datecomp.day = calendar.component(.day, from: modifiedDate)
    notification_datecomp.month = calendar.component(.month, from: modifiedDate)
    notification_datecomp.year = calendar.component(.year, from: modifiedDate)
    
    if let notificationTimeAtWholeDay = event.notificationTimeAtWholeDay {
        notification_datecomp.hour = calendar.component(.hour, from: notificationTimeAtWholeDay)
        notification_datecomp.minute = calendar.component(.minute, from: notificationTimeAtWholeDay)
    } else {
        notification_datecomp.hour = calendar.component(.hour, from: modifiedDate)
        notification_datecomp.minute = calendar.component(.minute, from: modifiedDate)
    }
    
    if let repetitionInterval = event.repetitionInterval {
        if repetitionInterval == "Daily" {
            notification_datecomp.day = nil
            notification_datecomp.month = nil
            notification_datecomp.year = nil
        }
        else if repetitionInterval == "Monthly" {
            notification_datecomp.month = nil
            notification_datecomp.year = nil
        }
        else if repetitionInterval == "Yearly" {
            notification_datecomp.month = nil
        }
        if repetitionInterval == "Weekly" {
            notification_datecomp.day = nil
            notification_datecomp.month = nil
            notification_datecomp.year = nil
            notification_datecomp.weekday = calendar.component(.weekday, from: modifiedDate)
        }
        
    }
    //Offset datecomponents by the amount of time specified in notificationMinutesBefore
    
    let notification_trigger = UNCalendarNotificationTrigger(dateMatching: notification_datecomp, repeats: event.repetition)
    let notification_request = UNNotificationRequest(identifier: event.key!.uuidString + UUID().uuidString, content: new_notification, trigger: notification_trigger)
   //TODO:Remove after wholeDay is fixed
    print ("Requesting notification at:")
    print(notification_datecomp)
    center.add(notification_request)}


private func createNotificationRepetitions(amount: Int, event: Event) {
    //Create 10 seperate events basically :D Always add the offset to them
    var notification_datecomp = DateComponents()
    
    let date = event.startdate! //TODO: Consider if there are any cases where this might lead to a crash.
    //TODO: Make this work for a wholeDay (needs fixes in AddEventSwift, as .notificationMinutesBefore is set to 0 when wholeDay is true!)
    let calendar = Calendar.current
    var modifiedDate : Date
    
    if event.wholeDay {
        modifiedDate = Calendar.current.date(byAdding: .day, value: -Int(event.notificationMinutesBefore / 1440), to: date)! //convert to date first
    } else {
        modifiedDate = Calendar.current.date(byAdding: .minute, value: -Int(event.notificationMinutesBefore), to: date)!
    }

    notification_datecomp.day = calendar.component(.day, from: modifiedDate)
    notification_datecomp.month = calendar.component(.month, from: modifiedDate)
    notification_datecomp.year = calendar.component(.year, from: modifiedDate)
    
    if let notificationTimeAtWholeDay = event.notificationTimeAtWholeDay {
        notification_datecomp.hour = calendar.component(.hour, from: notificationTimeAtWholeDay)
        notification_datecomp.minute = calendar.component(.minute, from: notificationTimeAtWholeDay)
    } else {
        notification_datecomp.hour = calendar.component(.hour, from: modifiedDate)
        notification_datecomp.minute = calendar.component(.minute, from: modifiedDate)
    }

    
    for _ in 1...amount {
        
        let new_notification = UNMutableNotificationContent()
        new_notification.title = "Calendar Event Coming Up"
        
        if let name = event.name {
            new_notification.subtitle = name
        } else {
            new_notification.subtitle = ""
        }
        
        new_notification.sound = .default
        new_notification.badge = 1
        let notification_trigger = UNCalendarNotificationTrigger(dateMatching: notification_datecomp, repeats: false)
        let notification_request = UNNotificationRequest(identifier: event.key!.uuidString + UUID().uuidString, content: new_notification, trigger: notification_trigger)
        
        print("Requesting a notification on \(notification_datecomp.day!)/\(notification_datecomp.month!)/\(notification_datecomp.year!) at \(notification_datecomp.hour!):\(notification_datecomp.minute!)" ) //TODO: REMOVE; THIS --WILL-- CAUSE A CRASH ONE DAY OTHERWISE.
        center.add(notification_request)
        
        //incrementDateComp(datecomp: notification_datecomp, days: ())
        var days : Int = Int(event.notificationMinutesBefore) / 1440 //todo: fix in addeventview
        days = 7 //TODO: REMOVE THIS IS ONLY HERE UNTIL THE BUG FROM ABOVE GETS FIXED: DO NOT FORGET TO REMOVE::::::
        var datecomp_date = Calendar.current.date(from: notification_datecomp)!
        datecomp_date = Calendar.current.date(byAdding: .day, value: days, to: datecomp_date)! //convert to date first
        notification_datecomp.day = Calendar.current.component(.day, from: datecomp_date)
        notification_datecomp.month = Calendar.current.component(.month, from: datecomp_date)
        notification_datecomp.year = Calendar.current.component(.year, from: datecomp_date)

    }
    
}

private func createNotificationRepetitions(enddate: Date, event: Event) {
    var notification_datecomp = DateComponents()
    
    let date = event.startdate! //TODO: Consider if there are any cases where this might lead to a crash.
    //TODO: Make this work for a wholeDay (needs fixes in AddEventSwift, as .notificationMinutesBefore is set to 0 when wholeDay is true!)
    let calendar = Calendar.current
    var modifiedDate : Date
    
    if event.wholeDay {
        modifiedDate = Calendar.current.date(byAdding: .day, value: -Int(event.notificationMinutesBefore / 1440), to: date)! //convert to date first
    } else {
        modifiedDate = Calendar.current.date(byAdding: .minute, value: -Int(event.notificationMinutesBefore), to: date)!
    }

    notification_datecomp.day = calendar.component(.day, from: modifiedDate)
    notification_datecomp.month = calendar.component(.month, from: modifiedDate)
    notification_datecomp.year = calendar.component(.year, from: modifiedDate)
    
    if let notificationTimeAtWholeDay = event.notificationTimeAtWholeDay {
        notification_datecomp.hour = calendar.component(.hour, from: notificationTimeAtWholeDay)
        notification_datecomp.minute = calendar.component(.minute, from: notificationTimeAtWholeDay)
    } else {
        notification_datecomp.hour = calendar.component(.hour, from: modifiedDate)
        notification_datecomp.minute = calendar.component(.minute, from: modifiedDate)
    }

    while (Calendar.current.date(from: notification_datecomp)! <= enddate) {
        
        let new_notification = UNMutableNotificationContent()
        new_notification.title = "Calendar Event Coming Up"
        
        if let name = event.name {
            new_notification.subtitle = name
        } else {
            new_notification.subtitle = ""
        }
        
        new_notification.sound = .default
        new_notification.badge = 1
        let notification_trigger = UNCalendarNotificationTrigger(dateMatching: notification_datecomp, repeats: false)
        let notification_request = UNNotificationRequest(identifier: event.key!.uuidString + UUID().uuidString, content: new_notification, trigger: notification_trigger)
        
        print("Requesting a notification on \(notification_datecomp.day!)/\(notification_datecomp.month!)/\(notification_datecomp.year!) at \(notification_datecomp.hour!):\(notification_datecomp.minute!)" ) //TODO: REMOVE; THIS --WILL-- CAUSE A CRASH ONE DAY OTHERWISE.
        center.add(notification_request)
        
        //incrementDateComp(datecomp: notification_datecomp, days: ())
        var days : Int = Int(event.notificationMinutesBefore) / 1440 //todo: fix in addeventview
        days = 7 //TODO: REMOVE THIS IS ONLY HERE UNTIL THE BUG FROM ABOVE GETS FIXED: DO NOT FORGET TO REMOVE::::::
        var datecomp_date = Calendar.current.date(from: notification_datecomp)!
        datecomp_date = Calendar.current.date(byAdding: .day, value: days, to: datecomp_date)! //convert to date first
        notification_datecomp.day = Calendar.current.component(.day, from: datecomp_date)
        notification_datecomp.month = Calendar.current.component(.month, from: datecomp_date)
        notification_datecomp.year = Calendar.current.component(.year, from: datecomp_date)
        
        /*
        print ("Here are the variables before the next comparison")
        print ("currentnotif:\(Calendar.current.date(from: notification_datecomp)! )")
        print ("emddate:\(enddate)") */

    }
}

func removeNotification(eventuuid : String) {
    
    center.getPendingNotificationRequests { listofrequests in
        var to_remove : [String] = []
        for request in listofrequests {
            if request.identifier.hasPrefix(eventuuid) {
                to_remove.append(request.identifier)
            }
        }
        //center.removeAllPendingNotificationRequests()
        print(to_remove)
        center.removePendingNotificationRequests(withIdentifiers: to_remove)
        
    }
}

//called after an event has been edited
func updateNotification(event: Event) {
    removeNotification(eventuuid: event.key!.uuidString)
    scheduleNotification(event: event)
}
