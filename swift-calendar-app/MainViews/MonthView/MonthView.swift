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
    @Binding var displayedMonth: DateComponents
    @State private var pickerSelection: PickerSelection = .current
    @ObservedObject var viewModel: MonthViewModel
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        VStack() {
            MonthViewMonthAndYear(dateComponents: $displayedMonth)
            Spacer()
                .frame(minHeight: 10, maxHeight: 10)
            MonthViewCalendar(daysOfMonth: viewModel.daysOfMonth)
            Spacer()
            
            Picker("", selection: $pickerSelection) {
                Text(String((viewModel.previousMonth?.month)! as Int)).tag(PickerSelection.previous)
                Text(String((viewModel.displayedMonth?.month!)! as Int)).tag(PickerSelection.current)
                Text(String((viewModel.nextMonth?.month!)! as Int)).tag(PickerSelection.next)
            }
            
            .onChange(of: pickerSelection){ _ in
                if(pickerSelection == .previous){
                    //dateComponents = getNextOrPreviousMonth(components: dateComponents, next: false)!
                    viewModel.moveBackwards()
                }
                if(pickerSelection == .next){
                   //dateComponents = getNextOrPreviousMonth(components: dateComponents, next: true)!
                    viewModel.moveForward()
                }
                
                displayedMonth = viewModel.displayedMonth!
                // reset picker
                pickerSelection = .current
            }
            
            .onAppear {
                displayedMonth = viewModel.displayedMonth!
            }
            .padding()
            .pickerStyle(.segmented)
            .colorMultiply(Color(getAccentColorString(from: colorScheme)))
        }
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
        .environmentObject(viewModel)
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(displayedMonth: .constant(Calendar.current.dateComponents([.month, .year], from: Date.now)), viewModel: MonthViewModel())
    }
}
