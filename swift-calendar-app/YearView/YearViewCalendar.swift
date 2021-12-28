//
//  YearViewCalendar.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

struct YearViewCalendar: View {
    var year: Int
    let montlist = ["Jan.", "Feb.","Mar.","Apr.","May","June","July","Aug.","Sep.","Oct.","Nov.","Dec."]
    
    var body: some View {
        VStack {
            
            VStack {

                // Notice: 0 <= startOfMonthDay <= 6, 27 <= lastDayOfMonth <= 31
                ForEach([0,3,6,9], id:\.self)  { row in
                    HStack {
                        ForEach([1,2,3], id:\.self) { monthofyear in
                            NavigationLink {
                                MonthView(month: monthofyear + row-1,year: year)
                            } label: {
                                YearViewMonthBox(month: montlist[monthofyear + row-1], width: 110, length: 110, startOfMonthDay: 6, lastDayOfMonth: 31)
                            .padding(.all, 1)
                            }
                        }
                    }
                }
            }
        }
        
    }
}

struct YearViewCalendar_Previews: PreviewProvider {
    static var previews: some View {
        YearViewCalendar(year: 2021)
    }
}
