//
//  AddCalendarView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 02.01.22.
//

import SwiftUI

struct AddCalendarView: View {
    @State var calendarName = ""
    @State var color = "Yellow"
    
    @State var confirmationShown = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @Binding var saveCalendar: Bool
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ]
    ) var calendars: FetchedResults<MCalendar>
    
    var body: some View {
        NavigationView{
            List{
                Section{
                TextField("Name", text: $calendarName).padding()
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
                                addCalendar(name: calendarName, color: color)
                                saveCalendar = true
                                dismiss()
                            }.foregroundColor(Color(getAccentColor()))
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
                    Picker("Color", selection: $color){
                        ForEach(colorStrings, id: \.self){ color in
                            HStack{
                                Image(systemName: "square.fill")
                                    .foregroundColor(getColorFromString(stringColor: color))
                                Text(color)
                            }.padding()
                        }
                    }
                }
            }
        }
    }
    
    func addCalendar(name: String, color: String){
        let calendar = MCalendar(context: moc)
        calendar.key = UUID()
        calendar.name = name
        calendar.color = color
        
        try? moc.save()
    }
}

struct AddCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        AddCalendarView(saveCalendar: .constant(true))
    }
}
