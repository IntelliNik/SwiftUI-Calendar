//
//  DayView.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 08.01.22.
//

import SwiftUI

struct DayView: View {
    @Binding var dateComponents: DateComponents
    @State private var pickerSelection: PickerSelection = .current
    
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ],
        predicate: NSPredicate(format: "startdate >= %@ && startdate <= %@", getBeginningOfDay(date: Date.now) as NSDate, getEndOfDay(date: Date.now) as NSDate)
    ) var eventsToday: FetchedResults<Event>
    
    @AppStorage("colorScheme") private var colorScheme = "red"

    var body: some View {
        VStack{
            DayViewHeader(dateComponents: $dateComponents)
                .padding()

            DayViewTime(dateComponents: $dateComponents, eventsToday: eventsToday)
            
            Picker("", selection: $pickerSelection) {
                let next = getNextOrPreviousDay(components: dateComponents, next: true)
                let previous = getNextOrPreviousDay(components: dateComponents, next: false)
                let month_prev = Month_short[previous!.month!-1]
                let month_next = Month_short[next!.month!-1]
                let month_cur = Month_short[dateComponents.month!-1]
                Text("\(month_prev) /  \(previous!.day!)").tag(PickerSelection.previous)
                Text("\(month_cur) / \(dateComponents.day!)").tag(PickerSelection.current)
                Text("\(month_next) / \(next!.day!)").tag(PickerSelection.next)
            }
            .onChange(of: pickerSelection){ _ in
                if(pickerSelection == .previous){
                    dateComponents = getNextOrPreviousDay(components: dateComponents, next: false)!
                }
                if(pickerSelection == .next){
                    dateComponents = getNextOrPreviousDay(components: dateComponents, next: true)!
                }
                // reset picker
                pickerSelection = .current
            }
            .padding()
            .pickerStyle(.segmented)
            .colorMultiply(Color(getAccentColorString(from: colorScheme)))
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

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)))
    }
}
