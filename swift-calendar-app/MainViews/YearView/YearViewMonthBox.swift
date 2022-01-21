//
//  YearViewDayBox.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

struct Part1View: View {
    var dateComponents: DateComponents
    var monthNum: Int
    var month : String
    var width, height: CGFloat
    
    @EnvironmentObject var currentTime: CurrentTime
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        Rectangle()
            .fill(.thinMaterial)
            .colorMultiply((dateComponents.year == currentTime.components.year && monthNum == currentTime.components.month) ? Color(getAccentColorString(from: colorScheme)) : .gray)
            .colorMultiply(Color(.sRGBLinear, red: 1 , green: 1, blue: 1, opacity: 0.3))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .frame(width: width, height: 20)
            .overlay(Text(String(month)).fontWeight(.heavy))
            .offset(x:0 , y: -((height-20)/2))
            .foregroundColor(.gray)
    }
}

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
                            .foregroundColor((dateComponents.year == currentTime.components.year && monthNum == currentTime.components.month && dayofweek+row == currentTime.components.day) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                    } else {
                        Text(String(dayofweek + row)).font(.custom("Calender", size: 7))
                            .foregroundColor((dateComponents.year == currentTime.components.year && monthNum == currentTime.components.month && dayofweek+row == currentTime.components.day) ? Color(getAccentColorString(from: colorScheme)) : .gray)
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
                Divider()
            }
        }
    }
}


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
                        .foregroundColor((dateComponents.year == currentTime.components.year && monthNum == currentTime.components.month && dayofweek-startOfMonthDay == currentTime.components.day) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                } else {
                    let text = "    "
                    Text(text).font(.custom("Calender", size: 7))
                        .foregroundColor(.gray)
                }
            }
        }
        Divider()
    }
}


struct YearViewMonthBox: View {
    var dateComponents: DateComponents
    var monthNum: Int
    var month : String
    
    var width, height: CGFloat
    
    var startOfMonthDay: Int
    var lastDayOfMonth: Int
    
    var body: some View {
        ZStack(alignment: .trailing) {
    
            Part1View(dateComponents: dateComponents, monthNum: monthNum, month: month, width: width, height:height)
            Part2View(width: width, height:height)
            
            VStack(alignment: .center, spacing: 2) {
                
                Part4View(dateComponents: dateComponents, monthNum: monthNum, startOfMonthDay: startOfMonthDay,width: width, height:height)
                ForEach([7,14,21,28,35], id:\.self)  { row in
                    let number = row - startOfMonthDay
                    Part3View(dateComponents: dateComponents, monthNum: monthNum, row: number, lastDayOfMonth: lastDayOfMonth,width: width, height:height)
                }
            }.offset(x:0 , y: 10)
        }
    }
}

struct YearViewDayBox_Previews: PreviewProvider {
    static var previews: some View {
        YearViewMonthBox(dateComponents: Calendar.current.dateComponents([.year, .month, .day, .weekOfYear], from: Date.now) , monthNum: 1, month: "Jan.", width: 45, height: 45, startOfMonthDay: 5, lastDayOfMonth: 31)
            .environmentObject(CurrentTime())
    }
}
