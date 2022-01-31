//
//  YearView.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI


// Main view for the YearView.
// This view uses YearViewYearAndToday and YearViewCalendar.
struct YearView: View {
    
    // dateComponents: the year which should be displayed
    @Binding var dateComponents: DateComponents
    @Binding var updateView: Bool
    
    @State var pickerSelection: PickerSelection = .current
    @State var offset = CGSize(width: 0, height: 0)
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        VStack {
            // Include YearViewYearAndToday
            YearViewYearAndToday(dateComponents: $dateComponents)
                .offset(offset)
            Spacer()
            // Include YearViewCalendar
            YearViewCalendar(dateComponents: $dateComponents, updateView: $updateView)
                .offset(offset)
            Spacer()
            // Picker to select the next or previous year
            Picker("", selection: $pickerSelection) {
                let next = getNextOrPreviousYear(components: dateComponents, next: true)
                let previous = getNextOrPreviousYear(components: dateComponents, next: false)
                Text(String((previous!.year!) as Int)).tag(PickerSelection.previous)
                Text(String((dateComponents.year!) as Int)).tag(PickerSelection.current)
                Text(String((next!.year!) as Int)).tag(PickerSelection.next)
            }
            .onChange(of: pickerSelection){ _ in
                // Depending on the picker selection the YearView for the next or previous opens
                if(pickerSelection == .previous){
                    withAnimation{
                        offset.width = 400
                    }
                    dateComponents = getNextOrPreviousYear(components: dateComponents, next: false)!
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                    dateComponents = getNextOrPreviousYear(components: dateComponents, next: true)!
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        offset.width = 400
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation{
                            offset.width = 0
                        }
                    }
                }
                // Reset picker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    pickerSelection = .current
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(Color(getAccentColorString(from: colorScheme)))
            .padding()
        }.padding()
            .gesture(
                DragGesture()
                    .onEnded(){gesture in
                        print(gesture)
                        // Include a gesture for the pickerSelection, i.e. the next or previous year
                        if(gesture.translation.width > 0){
                            pickerSelection = .previous
                        } else if(gesture.translation.width < 0){
                            pickerSelection = .next
                        }
                    }
            )
    }
}
