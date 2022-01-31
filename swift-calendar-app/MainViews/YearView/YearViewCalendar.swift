//
//  YearViewCalendar.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

// Subview for the YearView.
// This view opens 12 times the YearViewMonthBox for every month
struct YearViewCalendar: View {
    
    // dateComponents: the year which should be displayed
    @Binding var dateComponents: DateComponents
    @Binding var updateView: Bool
    
    // Strings to display at the top of the YearViewMonthBox
    let montlist = ["Jan.", "Feb.","Mar.","Apr.","May","June","July","Aug.","Sep.","Oct.","Nov.","Dec."]

    var body: some View {
        GeometryReader{ geo in
            VStack {
                VStack {
                    // We go through all months.
                    // We use two for loops to get the 4 x 3 matrix
                    ForEach([0,3,6,9], id:\.self)  { row in
                        HStack {
                            ForEach([1,2,3], id:\.self) { monthofyear in
                                // Button to go to the MonthView
                                Button(action: {
                                    dateComponents = setMonth(dateComponents: dateComponents, month: monthofyear + row)
                                    updateView = true
                                }){
                                    // Notice: 0 <= startOfMonthDay <= 6
                                    // and     27 <= lastDayOfMonth <= 31
                                    // (see functions below)
                                    YearViewMonthBox(dateComponents: dateComponents, monthNum: monthofyear + row, month: montlist[monthofyear + row-1], width: calculateWidth(geo: geo), height: calculateHeight(geo: geo), startOfMonthDay: getFirstDayOfMonth(year: dateComponents.year!, month:monthofyear + row), lastDayOfMonth: getNumberOfDaysOfMonth(year:dateComponents.year!,month:monthofyear + row))
                                .padding(.all, 1)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Computes the number of days of month in year
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
    
    // Computes the first day of month in year, i.e. monday, tuesday, ... , saturday or sunday
    func getFirstDayOfMonth(year:Int, month:Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        let date = Calendar.current.date(from: components)!
        let index = Calendar.current.component(.weekday, from: date)
        return index-2;
    }
    
    // Computes the width of a YearViewMonthBox depending on the display size
    func calculateWidth(geo:GeometryProxy) -> CGFloat {
        return geo.size.width/3.15;
    }
    
    // Computes the height of a YearViewMonthBox depending on the display size
    func calculateHeight(geo:GeometryProxy) -> CGFloat {
        return geo.size.height/4.6;
    }
}
