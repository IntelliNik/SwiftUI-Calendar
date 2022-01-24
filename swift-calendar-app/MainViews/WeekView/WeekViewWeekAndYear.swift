//
//  WeekViewWeekAndYear.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

struct WeekViewWeekAndYear: View {
    @Binding var dateComponents: DateComponents

    var body: some View {
        HStack(alignment: .bottom) {
            Spacer()
                .frame(width: 10, alignment: .leading)
                TodayButton(dateComponents: $dateComponents)
                Spacer()
                Text("W" + String(dateComponents.weekOfYear ?? getCurrentWeekOfYear()))
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
            
            Spacer()
            
            Text(String(dateComponents.year!)).font(.system(size: 30, weight: .bold, design: .monospaced))
            
            Spacer()
                .frame(width: 10, alignment: .trailing)
        }
    }
}

struct WeekViewWeekAndYear_Previews: PreviewProvider {
    static var previews: some View {
        WeekViewWeekAndYear(dateComponents: .constant(Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)))
    }
}
