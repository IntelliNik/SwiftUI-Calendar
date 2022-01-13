//
//  WeekViewDayBox.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

let daylist = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

struct WeekViewDayBox: View {
    @State var dateComponents: DateComponents
    var todo: Bool
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        
        ZStack {
            WeekViewRoundedRectangleBottom(dateComponents: dateComponents, height: height, width: width)
            if todo {
                WeekViewRoundedRectangleTopTodo(height: height, width: width)
            } else {
                WeekViewRoundedRectangleTop(dateComponents: dateComponents, height: height, width: width)
            }
        }
    }
}

struct WeekViewRoundedRectangleTop: View {
    @State var dateComponents: DateComponents
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: width, height: 10)
                .offset(x:0 , y: -((height - 20)/2) + 5)
                .foregroundColor(.gray)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: width, height: 20)
                .overlay(Text(daylist[transformWeekdayToGermanStandard(day: dateComponents.weekday ?? 1) - 1]).fontWeight(.heavy))
                .offset(x:0 , y: -((height - 20)/2))
                .foregroundColor(.gray)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(.gray)
                .frame(width: width, height: 1)
                .offset(x:0 , y: -((height - 20)/2) + 10)
        }
            
    }
}

struct WeekViewRoundedRectangleBottom: View {
    @State var dateComponents: DateComponents
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        ZStack {
            WeekEventView(dateComponents: dateComponents)
                .frame(width: width - 5, height: height - 30, alignment: .top)
                .offset(x: 0, y: 10)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.gray)
                .frame(width: width, height: height)
        }
    }
}

struct WeekViewRoundedRectangleTopTodo: View {
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: width, height: 10)
                .offset(x:0 , y: -((height - 20)/2) + 5)
                .foregroundColor(.gray)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: width, height: 20)
                .overlay(Text("todo").fontWeight(.heavy))
                .offset(x:0 , y: -((height - 20)/2))
                .foregroundColor(.gray)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(.gray)
                .frame(width: width, height: 1)
                .offset(x:0 , y: -((height - 20)/2) + 10)

            ScrollView{
                Text("AAA")
                Text("AAA")
                Text("AAA")
                Text("AAA")
            }
            .padding(.top, 30)
            .padding(.bottom, 10)

        }
    }
}

struct WeekViewDayBox_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeekViewDayBox(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now), todo: false, height: 220, width: 220)
            WeekViewRoundedRectangleTop(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now) , height: 220, width: 220)
            WeekViewRoundedRectangleBottom(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now), height: 220, width: 220)
        }
    }
}
