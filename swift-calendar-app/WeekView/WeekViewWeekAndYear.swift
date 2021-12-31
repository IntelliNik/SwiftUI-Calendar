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
            VStack(alignment: .leading) { //button and month
                TodayButton()
                Text("W" + String(dateComponents.weekOfYear!))
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                //Text(String(dateComponents.year!).prefix(2))
                //Text(String(dateComponents.year!).suffix(2))
                Text(String(dateComponents.year!))
            }.font(.system(size: 30, weight: .bold,
                           design: .monospaced))
        }
    }
}

struct WeekViewWeekAndYear_Previews: PreviewProvider {
    static var previews: some View {
        WeekViewWeekAndYear(dateComponents: .constant(Calendar.current.dateComponents([.month, .year, .weekOfYear], from: Date.now)))
    }
}
