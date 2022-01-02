//
//  AddCalendarView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 02.01.22.
//

import SwiftUI

struct AddCalendarView: View {
    @State var confirmationShown = false
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var saveCalendar: Bool
    
    var body: some View {
        NavigationView{
            Text("Add Calendar")                        .navigationTitle("Add calendar")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button("Discard"){
                            saveCalendar = false
                            confirmationShown = true
                        }
                        .foregroundColor(.gray)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Save calendar"){
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
                        dismiss()
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
