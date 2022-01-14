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
    @State var color: Int
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
/*
                TextField("Name", text: $name).padding()
                    .navigationTitle("Reconfigure calendar")
                    .onAppear {
                        name = mcalendar.name!
                        color = colorStrings.firstIndex(where: {$0 == mcalendar.color!})!
                    }
*/
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
        /*.onAppear {
            color = colorStrings.firstIndex(where: {$0 == mcalendar.color!})!
        }*/
    }
}

struct ModifyCalendar_Previews: PreviewProvider {
    static var previews: some View {
        ModifyCalendar(mcalendar: MCalendar(), color:0, showConfirmation: .constant(true))
    }
}
