//
//  YearViewDayBox.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

// This view is split into four different parts
// Part 1 and 2: Display the month box (depends on colorScheme and darkMode)
// Part 3: display the rows of month box for all weeks except the first week of month
// Part 4: display the row of month box for the first week of month
// YearViewMonthBox: Combines part 1 - 4 into one view

// Checks whether a month is the month of Date.now
// This function is used to give the month of Date.now a different color
func isToday(from dateComponents: DateComponents, and monthNum: Int, _ currentTime: CurrentTime) -> Bool {
    return dateComponents.year == currentTime.components.year && monthNum == currentTime.components.month
}

// Display the month box (depends on colorScheme and darkMode)
// Size depends on the display size (computed in YearViewCalendar)
struct Part1View: View {
    var dateComponents: DateComponents
    var monthNum: Int
    var month : String
    var width, height: CGFloat
    
    @EnvironmentObject var currentTime: CurrentTime
    @AppStorage("colorScheme") private var colorScheme = "red"
    @Environment(\.colorScheme) var darkMode
    
    var body: some View {
        if darkMode == .dark {
            Rectangle()
                .fill(.thinMaterial)
                .colorInvert()
                .colorMultiply((isToday(from: dateComponents, and: monthNum, currentTime)) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                .colorMultiply(Color(.sRGBLinear, red: 1 , green: 1, blue: 1, opacity: isToday(from: dateComponents, and: monthNum, currentTime) ? 0.7 : 0.3))
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .frame(width: width, height: 20)
                .overlay(Text(String(month)).fontWeight(.heavy))
                .offset(x:0 , y: -((height-20)/2))
                .foregroundColor(.gray)
        } else {
            Rectangle()
                .fill(.thinMaterial)
                .colorMultiply((isToday(from: dateComponents, and: monthNum, currentTime)) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                .colorMultiply(Color(.sRGBLinear, red: 1 , green: 1, blue: 1, opacity: 0.3))
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .frame(width: width, height: 20)
                .overlay(Text(String(month)).fontWeight(.heavy))
                .offset(x:0 , y: -((height-20)/2))
                .foregroundColor(.gray)
        }
    }
}

// Finalize the box
// Size depends on the display size (computed in YearViewCalendar)
struct Part2View: View {
    var width, height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.gray)
                .frame(width: width, height: height)
        
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .frame(width: width, height: 1)
            .offset(x:0 , y: -((height-20)/2)+10)
            .foregroundColor(.gray)
    }
}

// Display the rows of month box for all weeks except the first week of month
// Size depends on the display size (computed in YearViewCalendar)
struct Part3View: View {
    var dateComponents: DateComponents
    var monthNum: Int
    var row: Int
    var lastDayOfMonth: Int
    var width, height: CGFloat
    
    @EnvironmentObject var currentTime: CurrentTime
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        HStack(alignment: .center, spacing: nil) {
            ForEach([1,2,3,4,5,6,7], id:\.self) { dayofweek in
                if ((dayofweek + row) < lastDayOfMonth+1){
                    if ((dayofweek + row) < 10)
                    {
                        let text = "  "  + String(dayofweek + row)
                        Text(text).font(.custom("Calender", size: 7))
                            .foregroundColor((isToday(from: dateComponents, and: monthNum, currentTime) && dayofweek+row == currentTime.components.day) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                    } else {
                        Text(String(dayofweek + row)).font(.custom("Calender", size: 7))
                            .foregroundColor((isToday(from: dateComponents, and: monthNum, currentTime) && dayofweek+row == currentTime.components.day) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                    }
                } else {
                    let text = "    "
                    Text(text).font(.custom("Calender", size: 7))
                }
            }
        }
        if (row+7 < lastDayOfMonth)
        {
            if (row <= 28)
            {
                Rectangle().fill(Color(UIColor.lightGray)).frame(height: 0.75).padding(.trailing, 0.5)
            }
        }
    }
}

// Display the row of month box for the first week of month
// Size depends on the display size (computed in YearViewCalendar)
struct Part4View: View {
    var dateComponents: DateComponents
    var monthNum: Int
    var startOfMonthDay: Int
    var width, height: CGFloat
    
    @EnvironmentObject var currentTime: CurrentTime
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        HStack(alignment: .center, spacing: nil) {
            ForEach([1,2,3,4,5,6,7], id:\.self) { dayofweek in
                if ((dayofweek - 1) >= startOfMonthDay){
                    let text = "  "  + String(dayofweek - startOfMonthDay)
                    Text(text).font(.custom("Calender", size: 7))
                        .foregroundColor((isToday(from: dateComponents, and: monthNum, currentTime) && dayofweek-startOfMonthDay == currentTime.components.day) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                } else {
                    let text = "    "
                    Text(text).font(.custom("Calender", size: 7))
                        .foregroundColor(.gray)
                }
            }
        }
        Rectangle().fill(Color(UIColor.lightGray)).frame(height: 0.75).padding(.trailing, 0.5)
    }
}

// Displays one month box (depending on a month and year, i.e. dateComponents)
// Combines the parts 1 - 4 into one view
// Size depends on the display size (computed in YearViewCalendar)
struct YearViewMonthBox: View {
    var dateComponents: DateComponents
    var monthNum: Int
    // String to display for month
    var month : String
    
    // Computed in YearViewCalendar
    var width, height: CGFloat
    
    // First day of a month, i.e. monday, tuesday, ... , saturday or sunday
    var startOfMonthDay: Int
    // number of days of month
    var lastDayOfMonth: Int
    
    var body: some View {
        ZStack(alignment: .trailing) {
    
            // Part 1 and 2: Display the month box (depends on colorScheme and darkMode)
            Part1View(dateComponents: dateComponents, monthNum: monthNum, month: month, width: width, height:height)
            Part2View(width: width, height:height)
            
            VStack(alignment: .center, spacing: 2) {
                
                // Part 4: display the row of month box for the first week of month
                Part4View(dateComponents: dateComponents, monthNum: monthNum, startOfMonthDay: startOfMonthDay,width: width, height:height)
                
                ForEach([7,14,21,28,35], id:\.self)  { row in
                    let number = row - startOfMonthDay
                    // Part 3: display the rows of month box for all weeks except the first week of month
                    Part3View(dateComponents: dateComponents, monthNum: monthNum, row: number, lastDayOfMonth: lastDayOfMonth,width: width, height:height)
                }
            }.offset(x:0 , y: 10)
        }
    }
}
