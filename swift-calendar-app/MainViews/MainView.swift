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

    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        switch containedView{
        case .day:
            DayView(dateComponents: $dateComponents)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
        case .week:
            WeekView(updateView: $updateView, dateComponents: $dateComponents)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
                .onChange(of: updateView){_ in
                    if dateComponents.day != nil{
                        containedView = .day
                    }
                    updateView = false
                }
        case .month:
            MonthView(displayedMonth: $dateComponents, viewModel: MonthViewModel(dateComponents: dateComponents), updateView: $updateView)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
                .onChange(of: updateView){_ in
                    if dateComponents.day != nil{
                        containedView = .day
                    }
                        updateView = false
                    }
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
            SyncCalendarsView(parser: EKCal_Parser(viewContext: moc))
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
            
        }
        
        

    }
}
