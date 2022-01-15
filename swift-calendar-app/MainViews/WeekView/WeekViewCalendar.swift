//
//  WeekViewCalendar.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

func checkTodo(position: Int) -> Bool{
    if position > 7 {return true}
    return false
}

struct WeekViewCalendar: View {
    let dateComponents: DateComponents
    let height: CGFloat
    let width: CGFloat

    var body: some View {
        VStack {
            VStack {
                // Notice: 0 <= startOfMonthDay <= 6, 27 <= lastDayOfMonth <= 31
                ForEach([0,2,4,6], id:\.self)  { row in
                    HStack {
                        ForEach([1,2], id:\.self) { dayofweek in
                            let newComponent = getDayInWeek(of: dateComponents, day: dayofweek + row) ?? dateComponents
                            WeekViewDayBox(dateComponents: newComponent, todo: checkTodo(position: row + dayofweek), height: (height - 30)/4, width: (width - 10)/2)
                            if dayofweek == 1 {
                               Spacer()
                                    .frame(width: 10, alignment: .trailing)
                            }
                            
                            
                            // TODO: navigationLink breaks underlying ScrollView
                            /*NavigationLink {
                                MonthView(dateComponents: dateComponents)
                            } label: {
   
                            }*/
                        }
                    }
                    if row < 6 {
                        Spacer()
                            .frame(height: 10)
                    }
                }
            }
        }
    }
}

struct WeekViewCalendar_Previews: PreviewProvider {
    static var previews: some View {
        WeekViewCalendar(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now), height: 763, width: 390)
    }
}
