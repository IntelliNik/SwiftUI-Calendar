//
//  WeekView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

struct WeekView: View {
    
    @Binding var dateComponents: DateComponents
    @State var pickerSelection: PickerSelection = .current
    @EnvironmentObject var currColorScheme: CurrentColorScheme
    
    var body: some View {
        VStack{
            WeekViewWeekAndYear(dateComponents: $dateComponents)
            Spacer()
            GeometryReader { geo in
                HStack {
                    Spacer()
                        .frame(width: 10, alignment: .leading)
                    WeekViewCalendar(dateComponents: dateComponents, height: geo.size.height, width: geo.size.width - 20)
                    Spacer()
                        .frame(width: 10, alignment: .trailing)
                }
            }
            // The following is the picker at the bottom to change to
            // the next or the previous week
            Picker("", selection: $pickerSelection) {
                let next = getNextOrPreviousWeek(components: dateComponents, next: true)
                let previous = getNextOrPreviousWeek(components: dateComponents, next: false)
                Text("W\(previous!.weekOfYear!)").tag(PickerSelection.previous)
                Text("W\(dateComponents.weekOfYear!)").tag(PickerSelection.current)
                Text("W\(next!.weekOfYear!)").tag(PickerSelection.next)
            }
            .onChange(of: pickerSelection){ _ in
                if(pickerSelection == .previous){
                    dateComponents = getNextOrPreviousWeek(components: dateComponents, next: false)!
                }
                if(pickerSelection == .next){
                    dateComponents = getNextOrPreviousWeek(components: dateComponents, next: true)!
                }
                // reset picker
                pickerSelection = .current
            }
            .padding()
            .pickerStyle(.segmented)
            .colorMultiply(Color(currColorScheme))
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
    

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            //WeekView(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now))
              //  .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
            WeekView(dateComponents: .constant(Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
        }
        .environmentObject(CurrentColorScheme(.red))
    }
}
