//
//  MonthView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 13.01.22.
//

import SwiftUI

struct MonthView: View {
    @Binding var dateComponents: DateComponents

    var body: some View {
        VStack {
            ForEach([0,7,14,21,28], id:\.self)  { row in
                HStack {
                    ForEach([1,2,3,4,5,6,7], id:\.self) { dayofweek in
                       // MonthViewDayBox(date: dayofweek + row, width: 20, length: 20, fontSize: 12, rectangle: true)
                    }
                }
            }
        }
    }
}
