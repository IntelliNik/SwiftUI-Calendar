//
//  MonthViewMonthAndYear.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewMonthAndYear: View {
    @Binding var dateComponents: DateComponents
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    
    var body: some View {
        VStack() {
            HStack() {
                VStack(alignment: .leading) { //button and month
                    TodayButton(dateComponents: $dateComponents)
                    Text(Month[dateComponents.month!-1])
                        .font(.system(size: 45, weight: .bold, design: .monospaced))
                }
                Spacer()
                VStack(spacing: 0) {
                    Text(String(dateComponents.year!).prefix(2))
                    Text(String(dateComponents.year!).suffix(2))
                }.font(.system(size: 80, weight: .bold, design: .monospaced))
                    
            }.padding(.horizontal)
            Spacer()
                .frame(minHeight: 10, maxHeight: 10)
            //weekdays
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(["Mo", "Tu", "Wed", "Thu", "Fri", "Sat", "Sun"], id:\.self) { weekday in
                    Text(weekday)
                        .font(.subheadline)
                }
            }.padding(.horizontal)
        }
    }
}

struct MonthViewMonthAndYear_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewMonthAndYear(dateComponents: .constant(Calendar.current.dateComponents([.month, .year], from: Date.now)))
    }
}
