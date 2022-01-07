//
//  YearView.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

struct YearView: View {
    //struct Year {
    //    var month : Int
    //    var year : Int
    //}
    @State var dateComponents: DateComponents
    @State var pickerSelection: PickerSelection = .current
    @Binding var currentlySelectedView: ContainedView
    @Binding var changeToMonth: Int?
    
    var body: some View {
        
        VStack {
            YearViewYearAndToday(dateComponents: $dateComponents)
            Spacer()
            YearViewCalendar(dateComponents: $dateComponents, currentlySelectedView: $currentlySelectedView, changeToMonth: $changeToMonth)
            Spacer()
            Picker("", selection: $pickerSelection) {
                let next = getNextOrPreviousYear(components: dateComponents, next: true)
                let previous = getNextOrPreviousYear(components: dateComponents, next: false)
                Text("\(previous!.year!)").tag(PickerSelection.previous)
                Text("\(dateComponents.year!)").tag(PickerSelection.current)
                Text("\(next!.year!)").tag(PickerSelection.next)
            }
            .onChange(of: pickerSelection){ _ in
                if(pickerSelection == .previous){
                    dateComponents = getNextOrPreviousYear(components: dateComponents, next: false)!
                }
                if(pickerSelection == .next){
                    dateComponents = getNextOrPreviousYear(components: dateComponents, next: true)!
                }
                // reset picker
                pickerSelection = .current
            }
            .pickerStyle(.segmented)
            .colorMultiply(Color(getAccentColorString()))
            .padding()
            .gesture(
                DragGesture()
                    .onEnded(){gesture in
                        print(gesture)
                        if(gesture.translation.width < 0){
                            pickerSelection = .previous
                        } else if(gesture.translation.width > 0){
                            pickerSelection = .next
                        }
                    }
            )
        }.padding()
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(dateComponents: Calendar.current.dateComponents([.day, .month, .year], from: Date.now), currentlySelectedView: .constant(.year), changeToMonth: .constant(nil))
    }
}
