//
//  MonthViewCalendar.swift
//  DailyWidgetExtension
//
//  Created by Din Ferizovic on 28.01.22.
//

import SwiftUI

struct MonthViewCalendarWidget: View {
    var daysOfMonth : [String?]
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    
    let columnsWithWeekNumber = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
        var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                Spacer()
                LazyVGrid(columns:  columns, spacing: 5) {
                    
                    ForEach(daysOfMonth, id: \.self) { dc in
                        if let dc = dc {
                            if dc[dc.startIndex] == "W" {
                                Text(dc).font(.custom("Calender", size: 14))
                                    .foregroundColor(.gray)
                            } else {
                                DayBoxWidget(date: Int(dc) ?? 0, width: (geo.size.width)/(10), length: (geo.size.width)/(10))
                                    .padding(1)
                            }
                        } else {
                            Text(dc ?? "")
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
    }
}

