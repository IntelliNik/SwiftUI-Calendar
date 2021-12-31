//
//  WeekView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

struct WeekView: View {
    
    @State var dateComponents: DateComponents
    @State var pickerSelection: PickerSelection = .current
    
    var body: some View {
        VStack{
            WeekViewWeekAndYear(dateComponents: $dateComponents)
            Spacer()
            GeometryReader { geo in
                WeekViewCalendar(dateComponents: dateComponents, height: geo.size.height, width: geo.size.width)
            }
        }
    }
}
    

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeekView(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now))
                .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
            WeekView(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
        }
    }
}
