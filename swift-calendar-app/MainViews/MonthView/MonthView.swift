//
//  MonthView.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthView: View {
    @Binding var displayedMonth: DateComponents
    @State private var pickerSelection: PickerSelection = .current
    @ObservedObject var viewModel: MonthViewModel
    @Binding var updateView: Bool
    
    @State var offset = CGSize(width: 0, height: 0)
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    @AppStorage("weekNumbers") private var showWeekNumbers = true
    
    var body: some View {
        VStack() {
            MonthViewMonthAndYear(dateComponents: $displayedMonth)
                .offset(offset)
            Spacer()
                .frame(minHeight: 10, maxHeight: 10)
            //provides the actual calendar view of a month
            //showWeekNumbers ? $viewModel.daysOfMonthWithWeek :
            MonthViewCalendar(daysOfMonth: showWeekNumbers ? $viewModel.daysOfMonthWithWeek : $viewModel.daysOfMonth, updateView: $updateView, displayedMonth: $displayedMonth)
            //MonthViewCalendar(daysOfMonth: $viewModel.daysOfMonth, events: $viewModel.eventsOfMonth)
                .offset(offset)
            Spacer()
            
            Picker("", selection: $pickerSelection) {
                //picker always displays the current, the previous, and the next month
                Text(Month_short[((viewModel.previousMonth?.month)! as Int) - 1] + " " + String((viewModel.previousMonth?.year)! as Int)).tag(PickerSelection.previous)
                Text(Month_short[((viewModel.displayedMonth?.month!)! as Int) - 1] + " " + String((viewModel.displayedMonth?.year)! as Int)).tag(PickerSelection.current)
                Text(Month_short[((viewModel.nextMonth?.month!)! as Int) - 1] + " " + String((viewModel.nextMonth?.year)! as Int)).tag(PickerSelection.next)
            }
            
            .onChange(of: pickerSelection){ _ in
                //tags allow for inifinite looping by dynamically getting the next or previous month
                if(pickerSelection == .previous){
                    withAnimation{
                        offset.width = 500
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        //viewModel.moveBackwards()
                        displayedMonth = viewModel.getNextOrPreviousMonth(components: displayedMonth, next: false)!
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
                        //viewModel.moveForward()
                        displayedMonth = viewModel.getNextOrPreviousMonth(components: displayedMonth, next: true)!
                        offset.width = 500
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation{
                            offset.width = 0
                        }
                    }
                }
                
                displayedMonth = viewModel.displayedMonth!
                // reset picker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    pickerSelection = .current
                }
            }
            
            .onAppear {
                displayedMonth = viewModel.displayedMonth!
                viewModel.calcDaysOfMonth()
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
        .environmentObject(viewModel)
    }
}

/*struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(displayedMonth: .constant(Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)), viewModel: MonthViewModel(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)), updateView: .constant(false))
    }
}
*/

