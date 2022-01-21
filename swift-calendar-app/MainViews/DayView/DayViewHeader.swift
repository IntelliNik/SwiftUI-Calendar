//
//  DayViewHeader.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 08.01.22.
//

import SwiftUI

struct DayViewHeader: View {
    @Binding var dateComponents: DateComponents
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    @AppStorage("weekNumbers") private var showWeekNumbers = true
    
    var body: some View {
        
        
        HStack(alignment: .center) {
            VStack(alignment: .leading) { //button
                TodayButton(dateComponents: $dateComponents)
            }.padding()
            
            Spacer()
            
            HStack{
                Text("\(dateComponents.day!)").font(.system(size: 45, weight: .bold, design: .monospaced))
                    .lineLimit(1)
                    .frame(minWidth: 60)
                
                Spacer()
                    .frame(width: 15, alignment: .leading)
                
                //weekday is Int from 1 - 7 with 1 is Sun
                let weekday = weekDay[addWeekday(dateComponents: dateComponents).weekday!-1]
                let weekdayLong = weekDayLong[addWeekday(dateComponents: dateComponents).weekday!-1]
                let month = Month_short[dateComponents.month!-1]
                let year = dateComponents.year!
                let weekOfYear = addWeekOfYear(dateComponents: dateComponents).weekOfYear ?? getCurrentWeekOfYear()
                let year_formatted = formatYear(year: String(year))
                VStack(alignment: .leading, spacing: 0) {
                    if showWeekNumbers {
                        HStack{
                            Text("\(weekday)")
                                .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                            Spacer()
                            Text("W\(weekOfYear)").foregroundColor(.gray)
                                .frame(minWidth: 35, alignment: .trailing)
                        }.frame(width: 80, alignment: .leading)
                        HStack{
                            Text("\(month)")
                            Spacer()
                            Text("\(year_formatted)")
                        }.frame(width: 80, alignment: .leading)
                    } else {
                        HStack{
                            Text("\(weekdayLong)")
                                .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                        }.frame(width: 90, alignment: .leading)
                        HStack{
                            Text("\(month)")
                            //Spacer()
                            Text("\(year_formatted)")
                        }.frame(width: 90, alignment: .leading)
                    }
                }
                
                Spacer()
                    .frame(width: 10, alignment: .trailing)
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
        DayViewHeader(dateComponents: .constant(Calendar.current.dateComponents([.weekOfYear, .weekday, .day, .month, .year], from: Date.init(timeIntervalSinceNow: 90000))))
.previewInterfaceOrientation(.portrait)
    }
}

