//
//  CalendarView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 29.12.21.
//

import SwiftUI
import EventKit
import EventKitUI

enum ContainedView{
    case day
    case week
    case month
    case year
    case allEvents
    case sync
}



struct MainView: View {
    @Binding var containedView: ContainedView
    @State var updateView = false
    @State var dateComponents = Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)
    
    var body: some View {
        switch containedView{
        case .day:
            DayView(dateComponents: $dateComponents)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
        case .week:
            WeekView(dateComponents: $dateComponents)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
        case .month:
            MonthView(dateComponents: $dateComponents)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
        case .year:
            YearView(dateComponents: $dateComponents, updateView: $updateView)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
                .onChange(of: updateView){_ in
                    if dateComponents.month != nil{
                        containedView = .month
                    }
                    updateView = false
                }
        case .allEvents:
            AllEventsView()
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
            
        case .sync:
            let result = requestAccess()
            
            if result {
                SyncCalendarsView()
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
            }
            
        }
        

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


struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(containedView: .constant(.year))
    }
}
