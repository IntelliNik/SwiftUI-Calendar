//
//  CalendarView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 29.12.21.
//

import SwiftUI

enum ContainedView{
    case day
    case week
    case month
    case year
    case allEvents
}

struct MainView: View {
    @Binding var containedView: ContainedView
    @State var updateView = false
    @State var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date.now)
    
    
    var body: some View {
        switch containedView{
        case .day:
            DayView(dateComponents: $dateComponents)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
        case .week:
            Text("TODO")
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
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(containedView: .constant(.year))
    }
}
