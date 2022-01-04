//
//  AddCalendarView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 02.01.22.
//

import SwiftUI

struct AddCalendarView: View {
    @State var confirmationShown = false
    @State private var name: String = ""
    @State private var color = 0
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
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
                                    
                                    let calendar = MCalendar(context: moc)
                                    calendar.key = UUID()
                                    calendar.name = name
                                    calendar.color = colorStrings[color]
                                    
                                    try? moc.save()

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
                    Picker("Color", selection: $color) {
                        ForEach((0..<colorStrings.count)) { index in
                            HStack{
                                //TODO: Find another way to transform string to color
                                Image(systemName: "square.fill")
                                    .foregroundColor( getColorFromString(stringColor: colorStrings[index]) )
                                    .imageScale(.large)
                                Text("\(colorStrings[index])")
                            }.tag(index)
                        }
                    }.padding()
                }
            }
        }
    }
}

struct AddCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        AddCalendarView(saveCalendar: .constant(true))
    }
}

