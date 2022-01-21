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
    
    let eventStore : EKEventStore
    //func of UIViewControllerRepresentable
    //UIViewControllerRepresentable needs to be changed to UINavigationController:
    func makeUIViewController(context: UIViewControllerRepresentableContext<CalendarSelector>) -> UINavigationController {
        let calChooser = EKCalendarChooser(selectionStyle: .single, displayStyle: .allCalendars, entityType: .event, eventStore: eventStore)
        calChooser.showsDoneButton = true
        calChooser.showsCancelButton = true
        
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

            func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
                //parent.calendars = calendarChooser.selectedCalendars
                //parent.presentationMode.wrappedValue.dismiss()
            }

            func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
                //parent.presentationMode.wrappedValue.dismiss()
            }
    }
}
