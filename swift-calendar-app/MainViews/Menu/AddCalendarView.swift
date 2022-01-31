//
//  AddCalendarView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 02.01.22.
//

import SwiftUI
import WidgetKit

struct AddCalendarView: View {
    @State var confirmationShown = false
    @State private var name: String = ""
    @State private var color = 1
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    @Binding var saveCalendar: Bool
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    TextField("Name", text: $name).padding()
                        .navigationTitle("Add calendar")
                        .toolbar {
                            ToolbarItem(placement: .navigation) {
                                Button("Discard"){
                                    confirmationShown = true
                                }
                                .foregroundColor(.gray)
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button("Save calendar"){
                                    saveCalendar(name: name, color: colorStrings[color], defaultCal: false)

                                    saveCalendar = true
                                    dismiss()
                                }.foregroundColor(Color(getAccentColorString(from: colorScheme)))
                            }
                        }
                        .confirmationDialog(
                            "Are you sure?",
                             isPresented: $confirmationShown
                        ) {
                            Button("Discard calendar"){
                                saveCalendar = false
                                dismiss()
                            }
                        }
                }
                Section{
                    Picker("Color", selection: $color) {
                        ForEach((0..<colorStrings.count)) { index in
                            HStack{
                                Image(systemName: "square.fill")
                                    .foregroundColor(getColorFromString(stringColor: colorStrings[index]))
                                    .imageScale(.large)
                                Text("\(colorStrings[index])")
                            }.tag(index)
                        }
                    }.padding()
                }
            }
        }
    }
    
    public func saveCalendar(name: String, color: String, defaultCal: Bool){
        let calendar = MCalendar(context: moc)
        calendar.key = UUID()
        if (name != ""){
            calendar.name = name
        } else{
            calendar.name = "Calendar"
        }
        calendar.color = color
        calendar.defaultCalendar = false
        calendar.imported = false
        calendar.synchronized = false
        try? moc.save()
        WidgetCenter.shared.reloadAllTimelines()

    }
    
}
