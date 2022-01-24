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
    @Binding var dateComponents: DateComponents
    @Binding var updateView: Bool
    @State var pickerSelection: PickerSelection = .current
    
    @State var offset = CGSize(width: 0, height: 0)
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        VStack {
            YearViewYearAndToday(dateComponents: $dateComponents)
                .offset(offset)
            Spacer()
            YearViewCalendar(dateComponents: $dateComponents, updateView: $updateView)
                .offset(offset)
            Spacer()
            Picker("", selection: $pickerSelection) {
                let next = getNextOrPreviousYear(components: dateComponents, next: true)
                let previous = getNextOrPreviousYear(components: dateComponents, next: false)
                Text(String((previous!.year!) as Int)).tag(PickerSelection.previous)
                Text(String((dateComponents.year!) as Int)).tag(PickerSelection.current)
                Text(String((next!.year!) as Int)).tag(PickerSelection.next)
            }
            .onChange(of: pickerSelection){ _ in
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
                // reset picker
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
                        if(gesture.translation.width > 0){
                            pickerSelection = .previous
                        } else if(gesture.translation.width < 0){
                            pickerSelection = .next
                        }
                    }
            )

    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(dateComponents: .constant(Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)), updateView: .constant(false))
    }
}
