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
    @State var dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date.now)
    @State var changeToMonth: Int?
    
    
    var body: some View {
        switch containedView{
        case .day:
            Text("TODO")
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
        case .week:
            Text("TODO")
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
        case .month:
            MonthView(dateComponents: dateComponents)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
        case .year:
            YearView(dateComponents: dateComponents, currentlySelectedView: $containedView, changeToMonth: $changeToMonth)
                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
                .onChange(of: changeToMonth){ newMonth in
                    if let month = newMonth{
                        dateComponents = setMonth(dateComponents: dateComponents, month: month)
                    }
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
