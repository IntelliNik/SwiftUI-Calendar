//
//  WeekViewDayBox.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

struct WeekViewDayBox: View {
    var day: String
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        
        ZStack {
            WeekViewRoundedRectangleTop(day: day, height: height, width: width)
            WeekViewRoundedRectangleBottom(height: height, width: width)
        }
    }
}

struct WeekViewRoundedRectangleTop: View {
    var day: String
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(.thinMaterial)
            .frame(width: width, height: 20)
            .overlay(Text(day).fontWeight(.heavy))
            .offset(x:0 , y: -((height - 20)/2))
            .foregroundColor(.gray)
    }
}

struct WeekViewRoundedRectangleBottom: View {
    var height: CGFloat
    var width: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.gray)
                .frame(width: width, height: height)
        
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .frame(width: width, height: 1)
            .offset(x:0 , y: -((height - 20)/2)+10)
            .foregroundColor(.gray)
    }
}


struct WeekViewDayBox_Previews: PreviewProvider {
    static var previews: some View {
        WeekViewDayBox(day: "Monday", height: 220, width: 220)
    }
}
