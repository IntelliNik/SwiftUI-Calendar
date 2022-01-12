//
//  MonthViewCalendar.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewCalendar: View {
    var body: some View {
        VStack {
            HStack(alignment: .center) { //#warning: in case of localization, change!
                
                ForEach(["Mo", "Tu", "Wed", "Thu", "Fri", "Sat", "Sun"], id:\.self) { weekday in
                    Spacer()
                    Text(weekday)
                        .font(.subheadline)
                    Spacer()
                }
                
            }
            
            VStack {
                ForEach([0,7,14,21,28], id:\.self)  { row in
                    HStack {
                        ForEach([1,2,3,4,5,6,7], id:\.self) { dayofweek in
                            NavigationLink {
                                Text("Open Day View for the Day here!")
                            } label: {
                                MonthViewDayBox(date: dayofweek + row, width: 45, length: 45)
                            .padding(1)
                            }
                        }
                    }
                }
            }
        }
        
    }
}

struct MonthViewCalendar_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewCalendar()
    }
}
