//
//  DayView.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 08.01.22.
//
//  Main Day View

import SwiftUI

struct DayView: View {
    @Binding var dateComponents: DateComponents
    
    @State var dateShown : Date = Date.now
    @State private var pickerSelection: PickerSelection = .current
    @State var offset = CGSize(width: 0, height: 0)
    @State var refreshID = UUID()
    @FetchRequest var eventsToday: FetchedResults<Event>
    
    init(dateComponents: Binding<DateComponents>){
            self._dateComponents = dateComponents
            _eventsToday = FetchRequest<Event>(
                entity: Event.entity(),
                sortDescriptors: [
                    NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
                ],
                predicate: NSPredicate(format: "startdate <= %@ AND %@ <= enddate", getDateForStartdateComparison(from: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: self._dateShown.wrappedValue) )! as CVarArg, getDateForEnddateComparison(from: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: self._dateShown.wrappedValue ))! as CVarArg)
            )
        }
        
    @AppStorage("colorScheme") private var colorScheme = "red"

    var body: some View {
        VStack{
            DayViewHeader(dateComponents: $dateComponents)
                .offset(offset)
                .padding()
            
            DayViewTime(dateComponents: $dateComponents, dateToShow: $dateShown)
                .offset(offset)
            
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
                    withAnimation{
                        offset.width = 400
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dateComponents = getNextOrPreviousDay(components: dateComponents, next: false)!
                        dateShown = dateShown.addingTimeInterval(-TimeInterval(24*60*60)) //Add a day to the interview
                        offset.width = -400
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation{
                            offset.width = 0
                        }
                    }
                }
                if(pickerSelection == .next){
                    withAnimation{
                        offset.width = -400
                    }
                    
              
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        offset.width = 400
                        dateComponents = getNextOrPreviousDay(components: dateComponents, next: true)!
                        dateShown = dateShown.addingTimeInterval(TimeInterval(24*60*60)) //Add a day to the interview
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

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)))
    }
}
