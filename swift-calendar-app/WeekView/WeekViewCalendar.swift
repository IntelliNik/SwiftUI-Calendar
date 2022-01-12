//
//  WeekViewCalendar.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

struct WeekViewCalendar: View {
    @State var dateComponents: DateComponents
    var height: CGFloat
    var width: CGFloat
    
    let daylist = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "todo"]

    var body: some View {
        VStack {
            VStack {
                // Notice: 0 <= startOfMonthDay <= 6, 27 <= lastDayOfMonth <= 31
                ForEach([0,2,4,6], id:\.self)  { row in
                    HStack {
                        ForEach([1,2], id:\.self) { dayofweek in
                            NavigationLink {
                                MonthView(dateComponents: addMonthToComponents(components: dateComponents, month: dayofweek + 0)!)
                            } label: {
                                WeekViewDayBox(day: daylist[dayofweek + row-1], height: height/4.2, width: width/2.2)
                                    .padding(.all, 1)
                            }
                        }
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
