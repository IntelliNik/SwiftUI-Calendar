//
//  CalendarSelector.swift
//  swift-calendar-app
//
//  Created by Andreas RF Dymek on 21.01.22.
//

import Foundation
import EventKitUI
import SwiftUI

//to encorporate syncing with iCloud calendars, we need to include EKCalendarChooser
//Because we use SwiftUI we need to wrap with the UIViewControllerRepresentable protocol

struct CalendarSelector : UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    let eventStore : EKEventStore
    @Binding var calendars: Set<EKCalendar>?
    @Binding var selectedCalendars: Set<EKCalendar>?
    
    //func of UIViewControllerRepresentable
    //UIViewControllerRepresentable needs to be changed to UINavigationController:
    func makeUIViewController(context: UIViewControllerRepresentableContext<CalendarSelector>) -> UINavigationController {
        let calChooser = EKCalendarChooser(selectionStyle: .multiple, displayStyle: .allCalendars, entityType: .event, eventStore: eventStore)
        
        //show calendars that have been imported once
        calChooser.selectedCalendars = calendars ?? []
        calChooser.showsDoneButton = true
        calChooser.showsCancelButton = true
        //needed to notice button presses
        calChooser.delegate = context.coordinator
        //provide the EKCalendarChooser as the root of UINavigationController
        return UINavigationController(rootViewController: calChooser)
    }

    //func of UIViewControllerRepresentable
    func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<CalendarSelector>){
        //blank
    }
    
    //func of UIViewControllerRepresentable
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    
    class Coordinator: NSObject, UINavigationControllerDelegate, EKCalendarChooserDelegate {
            let parent: CalendarSelector

            init(_ parent: CalendarSelector) {
                self.parent = parent
            }

            func calendarChooserDidFinish(_ calChooser: EKCalendarChooser) {
                //setting the calendars variable to the selected Calendars from the view
                parent.presentationMode.wrappedValue.dismiss()
                //parent.calendars = calChooser.selectedCalendars
                parent.selectedCalendars = calChooser.selectedCalendars
            }

            func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
                parent.presentationMode.wrappedValue.dismiss()
            }
    }
}
