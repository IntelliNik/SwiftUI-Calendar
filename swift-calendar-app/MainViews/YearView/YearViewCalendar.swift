//
//  YearViewCalendar.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

struct YearViewCalendar: View {
    @Binding var dateComponents: DateComponents
    @Binding var updateView: Bool
    
    let montlist = ["Jan.", "Feb.","Mar.","Apr.","May","June","July","Aug.","Sep.","Oct.","Nov.","Dec."]

    var body: some View {
        GeometryReader{ geo in
            VStack {
                VStack {
                    // Notice: 0 <= startOfMonthDay <= 6, 27 <= lastDayOfMonth <= 31
                    ForEach([0,3,6,9], id:\.self)  { row in
                        HStack {
                            ForEach([1,2,3], id:\.self) { monthofyear in
                                Button(action: {
                                    dateComponents = setMonth(dateComponents: dateComponents, month: monthofyear + row)
                                    updateView = true
                                }){
                                    YearViewMonthBox(dateComponents: dateComponents, monthNum: monthofyear + row, month: montlist[monthofyear + row-1], width: calculateWidth(geo: geo), height: calculateHeight(geo: geo), startOfMonthDay: getFirstDayOfMonth(year: dateComponents.year!, month:monthofyear + row), lastDayOfMonth: getNumberOfDaysOfMonth(year:dateComponents.year!,month:monthofyear + row))
                                    //YearViewMonthBox(month: montlist[monthofyear + row-1], width: 110, height: 110, startOfMonthDay: 6, lastDayOfMonth: 31)
                                .padding(.all, 1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getNumberOfDaysOfMonth(year:Int, month:Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        let calendar = Calendar.current
        let date = Calendar.current.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays;
    }
    
    func getFirstDayOfMonth(year:Int, month:Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        let date = Calendar.current.date(from: components)!
        let index = Calendar.current.component(.weekday, from: date)
        return index-2;
    }
    
    func calculateWidth(geo:GeometryProxy) -> CGFloat {
        return geo.size.width/3.15;
    }
    
    func calculateHeight(geo:GeometryProxy) -> CGFloat {
        return geo.size.height/4.6;
    }
}

struct YearViewCalendar_Previews: PreviewProvider {
    static var previews: some View {
        YearViewCalendar(dateComponents: .constant(Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)), updateView: .constant(false))
            .environmentObject(CurrentTime())
    }
}
