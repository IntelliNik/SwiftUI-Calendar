//
//  WeekView.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

struct WeekView: View {
    
    @Binding var updateView: Bool
    @Binding var dateComponents: DateComponents
    @State var pickerSelection: PickerSelection = .current
    
    @State var offset = CGSize(width: 0, height: 0)
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        VStack{
            WeekViewWeekAndYear(dateComponents: $dateComponents)
                .offset(offset)
            .padding(.bottom)
            GeometryReader { geo in
                HStack {
                    Spacer()
                        .frame(width: 10, alignment: .leading)
                    WeekViewCalendar(updateView: $updateView, dateComponents: $dateComponents, height: geo.size.height, width: geo.size.width - 20)
                        .offset(offset)
                    Spacer()
                        .frame(width: 10, alignment: .trailing)
                }
            }
            // The following is the picker at the bottom to change to
            // the next or the previous week
            Picker("", selection: $pickerSelection) {
                let next = getNextOrPreviousWeek(components: dateComponents, next: true)
                let previous = getNextOrPreviousWeek(components: dateComponents, next: false)
                Text("W\(previous!.weekOfYear ?? getCurrentWeekOfYear())").tag(PickerSelection.previous)
                Text("W\(dateComponents.weekOfYear ?? getCurrentWeekOfYear())").tag(PickerSelection.current)
                Text("W\(next!.weekOfYear ?? getCurrentWeekOfYear())").tag(PickerSelection.next)
            }
            .onChange(of: pickerSelection){ _ in
                if(pickerSelection == .previous){
                    withAnimation{
                        offset.width = 400
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dateComponents = getNextOrPreviousWeek(components: dateComponents, next: false)!
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
                        dateComponents = getNextOrPreviousWeek(components: dateComponents, next: true)!
                        offset.width = 400
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
    

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            //WeekView(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now))
              //  .previewDevice(PreviewDevice(rawValue: "iPhone 13"))
            WeekView(updateView: .constant(false), dateComponents: .constant(Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
        }
    }
}
