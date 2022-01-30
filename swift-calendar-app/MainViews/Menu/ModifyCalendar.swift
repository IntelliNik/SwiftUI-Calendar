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
    @State var color: Int = 1
    @State private var name: String = ""
    
    @Binding var showConfirmation: Bool
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        Form{
            Section{
                TextField("Name", text: self.$mcalendar.name ?? "")
                    .padding()
                    .navigationTitle("Configure Calendar")
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
        .navigationBarItems(leading: Button(action : {
            mcalendar.setValue(colorStrings[color],forKey:"color")
            
            try? moc.save()
            
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
            HStack{
                Image(systemName: "chevron.left")
                    .font(Font.headline.weight(.bold))
                Text("Your Calendars")
            }
        })
    }
}
