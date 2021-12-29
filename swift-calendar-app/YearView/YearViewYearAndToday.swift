//
//  YearViewMonthAndYear.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

struct YearViewYearAndToday: View {
    @Binding var dateComponents : DateComponents

    var body: some View {
        HStack(alignment: .bottom, spacing: 160) {
            VStack(alignment: .leading) { //button
                TodayButton()
            }
            
            VStack(alignment: .leading, spacing: 170) { //Year
                Text(String(dateComponents.year!))
            }.font(.system(size: 30, weight: .bold,
                           design: .monospaced))
        }
    }
}

struct YearViewMonthAndYear_Previews: PreviewProvider {
    static var previews: some View {
        YearView(dateComponents: Calendar.current.dateComponents([.day, .month, .year], from: Date.now))
    }
}
