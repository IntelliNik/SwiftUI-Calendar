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
    
    let colorList = ["Yellow","Green","Blue","Pink","Purple","Gray","Black","Red","Orange","Brown","Cyan","Indigo"]
    
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
                                    calendar.color = colorList[color]
                                    
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
                        ForEach((0..<colorList.count)) { index in
                            HStack{
                                //TODO: Find another way to transform string to color
                                Image(systemName: "square.fill")
                                    .foregroundColor( getColor(stringColor: colorList[index]) )
                                    .imageScale(.large)
                                Text("\(colorList[index])")
                            }.tag(index)
                        }
                    }.padding()
                }
            }
        }
    }
    
    func getColor(stringColor: String) -> Color{
        switch stringColor{
            case "Yellow": return .yellow
            case "Green": return .green
            case "Blue": return .blue
            case "Pink": return .pink
            case "Purple": return .purple
            case "Gray": return .gray
            case "Black": return .black
            case "Red": return .red
            case "Orange": return .orange
            case "Brown": return .brown
            case "Cyan": return .cyan
            case "Indigo": return .indigo
            default: return .yellow
        }
    }
}

struct AddCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        AddCalendarView(saveCalendar: .constant(true))
    }
}

