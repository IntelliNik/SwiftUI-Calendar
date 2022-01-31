//
//  ModifyCalendar.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 04.01.22.
//

import SwiftUI
import WidgetKit


// View to modify a calendar, i.e. rename the calendar or select a new color
// This view is opened by EditCalendarView
struct ModifyCalendar: View {
    // Calendar which should be modified
    @State var mcalendar: MCalendar
    @State var confirmationShown = false
    // Selected color the mcalendar
    @State var color: Int = 1
    // name of mcalendar
    @State private var name: String = ""
    
    @Binding var showConfirmation: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        Form{
            Section{
                // Textfield to change the name of mcalendar
                // At start the old name is in the Textfield
                TextField("Name", text: self.$mcalendar.name ?? "")
                    .padding()
                    .navigationTitle("Configure Calendar")
            }
            Section{
                // Picker to change the color of mcalendar
                // At start the old color is selected
                Picker("Color", selection: $color) {
                    ForEach((0..<colorStrings.count)) { index in
                        HStack{
                            Image(systemName: "square.fill")
                                .foregroundColor( getColorFromString(stringColor: colorStrings[index]) )
                                .imageScale(.large)
                            Text("\(colorStrings[index])")
                        }.tag(index)
                    }
                }.padding()
            }
        }
        .navigationBarItems(leading: Button(action : {
            // Save the new values
            
            // name is directly stored in the textfield
            
            // Set the new value for the color
            mcalendar.setValue(colorStrings[color],forKey:"color")
            
            // Save the new values in data core
            try? moc.save()
            WidgetCenter.shared.reloadAllTimelines()
            
            withAnimation{
                showConfirmation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation{
                    showConfirmation = false
                }
            }
            
            self.mode.wrappedValue.dismiss()
        }){
            // Option to go back
            HStack{
                Image(systemName: "chevron.left")
                    .font(Font.headline.weight(.bold))
                Text("Your Calendars")
            }
        })
    }
}
