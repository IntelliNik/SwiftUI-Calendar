//
//  MonthViewMonthAndYear.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewMonthAndYear: View {
    @Binding var dateComponents: DateComponents

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) { //button and month
                TodayButton(dateComponents: $dateComponents)
                Text(Month[dateComponents.month!-1])
                    .font(.system(size: 45, weight: .bold, design: .monospaced))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(String(dateComponents.year!).prefix(2))
                Text(String(dateComponents.year!).suffix(2))
            }.font(.system(size: 80, weight: .bold,
                           design: .monospaced))
        }
    }
}

struct MonthViewMonthAndYear_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewMonthAndYear(dateComponents: .constant(Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)))
            .environmentObject(CurrentColorScheme(.red))
    }
}
