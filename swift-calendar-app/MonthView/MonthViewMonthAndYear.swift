//
//  MonthViewMonthAndYear.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewMonthAndYear: View {
    var month : String
    var year : Int

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) { //button and month
                TodayButton()
                Text(month)
                    .font(.system(size: 45, weight: .bold, design: .monospaced))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                Text(String(year).prefix(2))
                Text(String(year).suffix(2))
            }.font(.system(size: 80, weight: .bold,
                           design: .monospaced))
        }
    }
}

struct MonthViewMonthAndYear_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewMonthAndYear(month: "November", year: 2021)
    }
}
