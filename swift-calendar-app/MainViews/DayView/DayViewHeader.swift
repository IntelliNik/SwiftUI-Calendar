//
//  DayViewHeader.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 08.01.22.
//

import SwiftUI

struct DayViewHeader: View {
    @Binding var dateComponents: DateComponents
    
    var body: some View {
        
        HStack(alignment: .center) {
            VStack(alignment: .leading) { //button
                TodayButton()
            }.padding()
            
            Spacer()
            
            HStack{
                Text("\(dateComponents.day!)").font(.system(size: 45, weight: .bold, design: .monospaced))
                //weekday is Int from 1 - 7 with 1 is Sun
                let weekday = Weekday[addWeekday(dateComponents: dateComponents).weekday!-1]
                let month = Month_short[dateComponents.month!-1]
                let year = dateComponents.year!
                let year_formatted = formatYear(year: String(year))
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(weekday)")
                    HStack{
                        Text("\(month)")
                        Text("\(year_formatted)")
                    }
                }.padding()
            }
        }
    }
}

func formatYear(year: String) -> String{
    var str = year
    let removeCharacters: Set<Character> = ["'"]
    str.removeAll(where: { removeCharacters.contains($0) } )
    return str
}


struct DayViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        DayViewHeader(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)))
.previewInterfaceOrientation(.portrait)
    }
}
