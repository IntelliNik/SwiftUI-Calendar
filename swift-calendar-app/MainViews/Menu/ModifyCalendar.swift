//
//  ModifyCalendar.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 04.01.22.
//

import SwiftUI

struct ModifyCalendar: View {
    @State var mcalendar: MCalendar
    @State var confirmationShown = false
    @State private var name: String = ""
    @State private var color: Int = 0
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @Binding var saveCalendar: Bool
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    TextField("Name", text: $name).padding()
                        .navigationTitle("Reconfigure calendar")
                        .toolbar {
                            ToolbarItem(placement: .navigation) {
                                Button("Discard"){
                                    confirmationShown = true
                                }
                                .foregroundColor(.gray)
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button("Save calendar"){
                                    
                                    mcalendar.setValue(name,forKey: "name")
                                    mcalendar.setValue(colorStrings[color],forKey:"color")
                                    
                                    try? moc.save()

                                    saveCalendar = true
                                    dismiss()
                                }.foregroundColor(Color(getAccentColorString()))
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
                                    .foregroundColor( getColorFromString(stringColor: colorStrings[index]) )
                                    .imageScale(.large)
                                Text("\(colorStrings[index])")
                            }.tag(index)
                        }
                    }.padding()
                }
            }
        }
        .onAppear {
            name = mcalendar.name!
            color = colorStrings.firstIndex(where: {$0 == mcalendar.color!})!
        }
    }
    
}
