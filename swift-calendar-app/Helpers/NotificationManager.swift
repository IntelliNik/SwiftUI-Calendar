//
//  NotificationManager.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 17.01.22.
//

import Foundation
import UserNotifications

let center = UNUserNotificationCenter.current()

//So we don't need two functions for scheduleNotification (ForeverEvent vs Event)
private struct EventContents {
    let name : String
    let wholeDay: Bool
    let uuid : String
    let notificationMinutesBefore : Int
    let startDate : Date
    let notificationTimeAtWholeDay : Date?
    let forever : Bool
    let repetitionInterval : String?
}

func scheduleNotification (event: ForeverEvent) {
    let event_contents = EventContents(name: event.name!, wholeDay: event.wholeDay, uuid: event.key!.uuidString, notificationMinutesBefore: Int(event.notificationMinutesBefore), startDate: event.startdate!, notificationTimeAtWholeDay: event.notificationTimeAtWholeDay, forever: true, repetitionInterval: event.repetitionInterval)
    
    scheduleNotification(event: event_contents)
}

func scheduleNotification (event: Event) {
    let event_contents = EventContents(name: event.name!, wholeDay: event.wholeDay, uuid: event.key!.uuidString, notificationMinutesBefore: Int(event.notificationMinutesBefore), startDate: event.startdate!, notificationTimeAtWholeDay: event.notificationTimeAtWholeDay, forever: false, repetitionInterval: event.repetitionInterval)
    
    scheduleNotification(event: event_contents)
}

private func scheduleNotification(event: EventContents) {
    var notification_time = DateComponents()
    let calendar = Calendar.current
    var offset_date : Date //In order to offset the minutesBefore/days before
    let notification_id : String = event.uuid + "_notif"
    
    if event.wholeDay {
        offset_date = Calendar.current.date(byAdding: .day, value: -(event.notificationMinutesBefore / 1440), to: event.startDate)!
    } else {
        offset_date = Calendar.current.date(byAdding: .minute, value: -Int(event.notificationMinutesBefore), to: event.startDate)!
    }

    notification_time.day = calendar.component(.day, from: offset_date)
    notification_time.month = calendar.component(.month, from: offset_date)
    notification_time.year = calendar.component(.year, from: offset_date)
    
    if let notificationTimeAtWholeDay = event.notificationTimeAtWholeDay {
        notification_time.hour = calendar.component(.hour, from: notificationTimeAtWholeDay)
        notification_time.minute = calendar.component(.minute, from: notificationTimeAtWholeDay)
    } else {
        notification_time.hour = calendar.component(.hour, from: offset_date)
        notification_time.minute = calendar.component(.minute, from: offset_date)
    }
    
    if event.forever {
        if let repetitionInterval = event.repetitionInterval  {
                if repetitionInterval == "Daily" {
                    notification_time.day = nil
                    notification_time.month = nil
                    notification_time.year = nil
                }
                else if repetitionInterval == "Monthly" {
                    notification_time.month = nil
                    notification_time.year = nil
                }
                else if repetitionInterval == "Yearly" {
                    notification_time.month = nil
                }
                else if repetitionInterval == "Weekly" {
                    notification_time.day = nil
                    notification_time.month = nil
                    notification_time.year = nil
                    notification_time.weekday = calendar.component(.weekday, from: offset_date)
                }
        }
    }
    
    //Offset Datecomponents by the amount of time specified in notificationMinutesBefore
    let notification_trigger = UNCalendarNotificationTrigger(dateMatching: notification_time,
                                                             repeats: event.forever)
    let notification_request = UNNotificationRequest(identifier: notification_id,
                                                     content: createNotificationContent(name: event.name),
                                                     trigger: notification_trigger)
    center.add(notification_request)
}

//In order to avoid foreverevent vs event, we just use the uuid <3
func removeNotificationByUUID(eventuuid : String) {
    center.getPendingNotificationRequests { listofrequests in
        var notification_to_remove : [String] = []
        for request in listofrequests {
            if request.identifier.hasPrefix(eventuuid) {
                notification_to_remove.append(request.identifier)
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: notification_to_remove)
    }
}

private func createNotificationContent(name: String) -> UNMutableNotificationContent {
    let event_notification = UNMutableNotificationContent()
    event_notification.title = "Calendar Event Coming Up"
    event_notification.subtitle = name
    event_notification.sound = .default
    event_notification.badge = 1
    return event_notification
}

func updateNotification(event: Event) {
    scheduleNotification(event: event)
}

func updateNotification(event: ForeverEvent) {
    scheduleNotification(event: event)
}
