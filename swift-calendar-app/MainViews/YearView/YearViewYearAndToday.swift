//
//  YearViewMonthAndYear.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

// Subview for the YearView.
// This view displays the TodayButton and the current year (depending on dateComponents)
struct YearViewYearAndToday: View {
    @Binding var dateComponents : DateComponents

    var body: some View {
        HStack(alignment: .bottom, spacing: 160) {
            // Display the TodayButton
            VStack(alignment: .leading) { //button
                TodayButton(dateComponents: $dateComponents)
            }
            
            // Display the year depending on dateComponents
            VStack(alignment: .leading, spacing: 170) { //Year
                Text(String(dateComponents.year!))
            }.font(.system(size: 30, weight: .bold,
                           design: .monospaced))
        }
        Spacer().frame(height: 30)

    }
}
