//
//  MonthView.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthView: View {
    //struct Month {
    //    var month : Int
    //    var year : Int
    //}
    @State var dateComponents: DateComponents
    @State private var pickerSelection: PickerSelection = .current
    
    var body: some View {
        VStack {
            MonthViewMonthAndYear(dateComponents: $dateComponents)
                .padding()
            Spacer()
            MonthViewCalendar()
            Spacer()
            Picker("", selection: $pickerSelection) {
                let next = getNextOrPreviousMonth(components: dateComponents, next: true)
                let previous = getNextOrPreviousMonth(components: dateComponents, next: false)
                Text("\(previous!.month!) ' \(previous!.year!)").tag(PickerSelection.previous)
                Text("\(dateComponents.month!) ' \(dateComponents.year!)").tag(PickerSelection.current)
                Text("\(next!.month!) ' \(next!.year!)").tag(PickerSelection.next)
            }
            .onChange(of: pickerSelection){ _ in
                if(pickerSelection == .previous){
                    dateComponents = getNextOrPreviousMonth(components: dateComponents, next: false)!
                }
                if(pickerSelection == .next){
                    dateComponents = getNextOrPreviousMonth(components: dateComponents, next: true)!
                }
                // reset picker
                pickerSelection = .current
            }
            .padding()
            .pickerStyle(.segmented)
            .colorMultiply(Color(getAccentColor()))
            .gesture(
                DragGesture()
                    .onEnded(){gesture in
                        if(gesture.translation.width < 0){
                            pickerSelection = .previous
                        } else if(gesture.translation.width > 0){
                            pickerSelection = .next
                        }
                    }
            )
        }
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(dateComponents: Calendar.current.dateComponents([.month, .year], from: Date.now))
    }
}
