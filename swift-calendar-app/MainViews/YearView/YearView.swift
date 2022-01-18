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
    @Binding var displayedYear: DateComponents
    @Binding var updateView: Bool
    @State var pickerSelection: PickerSelection = .current
    @ObservedObject var viewModel: YearViewModel
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        VStack {
            YearViewYearAndToday(dateComponents: $displayedYear)
            Spacer()
            YearViewCalendar(dateComponents: $displayedYear, updateView: $updateView)
            Spacer()
            Picker("", selection: $pickerSelection) {
                Text(String((viewModel.previousYear?.year!)! as Int)).tag(PickerSelection.previous)
                Text(String((viewModel.displayedYear?.year!)! as Int)).tag(PickerSelection.current)
                Text(String((viewModel.nextYear?.year!)! as Int)).tag(PickerSelection.next)
            }
            .onChange(of: pickerSelection){ _ in
                if(pickerSelection == .previous){
                    viewModel.moveBackwards()
                    displayedYear = viewModel.displayedYear!
                }
                if(pickerSelection == .next){
                    viewModel.moveForward()
                    displayedYear = viewModel.displayedYear!
                }
                // reset picker
                pickerSelection = .current
            }
            
            .onAppear {
                //viewModel.initYears()
                displayedYear = viewModel.displayedYear!
                print(displayedYear)
            }
            
            .pickerStyle(.segmented)
            .colorMultiply(Color(getAccentColorString(from: colorScheme)))
            .padding()
        }.padding()
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

    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(displayedYear: .constant(Calendar.current.dateComponents([.day, .month, .year], from: Date.now)), updateView: .constant(false), viewModel: YearViewModel())
    }
}
