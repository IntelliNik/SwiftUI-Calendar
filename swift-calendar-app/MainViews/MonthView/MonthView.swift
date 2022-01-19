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
    @Binding var dateComponents: DateComponents
    @State private var pickerSelection: PickerSelection = .current
    
    @State var offset = CGSize(width: 0, height: 0)
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        VStack {
            MonthViewMonthAndYear(dateComponents: $dateComponents)
                .offset(offset)
                .padding()
            Spacer()
            MonthViewCalendar()
                .offset(offset)
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
                    withAnimation{
                        offset.width = 500
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dateComponents = getNextOrPreviousMonth(components: dateComponents, next: false)!
                        offset.width = -500
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation{
                            offset.width = 0
                        }
                    }
                }
                if(pickerSelection == .next){
                    withAnimation{
                        offset.width = -500
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dateComponents = getNextOrPreviousMonth(components: dateComponents, next: true)!
                        offset.width = 500
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation{
                            offset.width = 0
                        }
                    }
                }
                // reset picker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    pickerSelection = .current
                }
            }
            .padding()
            .pickerStyle(.segmented)
            .colorMultiply(Color(getAccentColorString(from: colorScheme)))
        }
        .gesture(
            DragGesture()
                .onEnded(){gesture in
                    if(gesture.translation.width > 0){
                        pickerSelection = .previous
                    } else if(gesture.translation.width < 0){
                        pickerSelection = .next
                    }
                }
        )
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(dateComponents: .constant(Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)))
    }
}
