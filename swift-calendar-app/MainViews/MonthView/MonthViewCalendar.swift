//
//  MonthViewCalendar.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewCalendar: View {
    
    @Binding var daysOfMonth : [String?]
    @Binding var updateView: Bool
    @Binding var displayedMonth: DateComponents
    
    @AppStorage("weekNumbers") private var showWeekNumbers = true
    
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
                    VStack() {
                        LazyVGrid(columns: showWeekNumbers ? columnsWithWeekNumber : columns, spacing: 15) {
                            ForEach(daysOfMonth, id: \.self) { dc in
                                if let dc = dc {
                                    if dc[dc.startIndex] == "W" {
                                        Text(dc).font(.custom("Calender", size: 14))
                                            .foregroundColor(.gray)
                                    } else {
                                        Button(action: {
                                            displayedMonth = setDay(dateComponents: displayedMonth, day: Int(dc) ?? 0 )
                                            updateView = true
                                        }){
                                            MonthViewDayBox(displayedMonth: displayedMonth, date: Int(dc) ?? 0, width: (geo.size.width)/(showWeekNumbers ? 9.5 : 8.5), length: (geo.size.width)/(showWeekNumbers ? 9.5 : 8.5))
                                                .padding(1)
                                        }

                                    }
                                } else {
                                    Text(dc ?? "")
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
        }
    }
    
}



/*struct MonthViewCalendar_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewCalendar(dateComponents: .constant(Calendar.current.dateComponents([.month, .year], from: Date.now)))
    }
}*/
