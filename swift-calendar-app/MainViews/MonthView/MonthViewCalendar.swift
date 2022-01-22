//
//  MonthViewCalendar.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewCalendar: View {
    var daysOfMonth : [String?]
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
    ]
    
    let columnsWeekNumbers = [GridItem(.flexible())]
    
    var body: some View {
        HStack {
            LazyVGrid(columns: columnsWeekNumbers) {
                Text("W")
            }
            
            VStack() {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(daysOfMonth, id: \.self) { dc in
                        if(dc == nil){
                            Text(dc ?? "")
                        }
                        else {
                            MonthViewDayBox(date: Int(dc!) ?? 0, width: 45, length: 45)
                                .padding(1)
                        }
                         
                         //Text(dc ?? "")
                        }
                    }
                    .padding(.horizontal)
            }
        }
    }
}

/*struct MonthViewCalendar_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewCalendar(dateComponents: .constant(Calendar.current.dateComponents([.month, .year], from: Date.now)))
    }
}*/
