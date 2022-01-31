//
//  CalendarEditView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 04.01.22.
//

import SwiftUI
import WidgetKit

struct EditCalendarView: View {
    @State var saveSucessful = true
    @State var showAlert = false
    @State var showAddEventSheet = false
    @State var showReconfigure = false
    @State var showConfirmation = false
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ],
        predicate: NSPredicate(format: "defaultCalendar == NO")
    ) var calendars: FetchedResults<MCalendar>
    
    @Environment(\.managedObjectContext) var moc
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        ZStack{
            if(showConfirmation){
                ConfirmationBoxView(mode: .success, text: "Changes saved").zIndex(2)
            }
            NavigationView {
                List {
                    ForEach((0..<calendars.count), id: \.self) { index in
                        if (index < calendars.count) {
                            NavigationLink(
                                destination: ModifyCalendar(mcalendar: calendars[index], color: colorStrings.firstIndex(where: {$0 == calendars[index].color!}) ?? 1, showConfirmation: $showConfirmation).navigationBarBackButtonHidden(true)
                            ) {
                                Text("Calendar Name: \(calendars[index].name ?? "")")
                            }
                        }
                    }
                    .onDelete ( perform: removeCalendar)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {showAddEventSheet.toggle()}) {
                            Image(systemName: "plus")
                                .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                                .font(.system(size: 16))
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        EditButton()
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Your Calendars")
                .sheet(isPresented: $showAddEventSheet){
                    AddCalendarView(saveCalendar: $saveSucessful)
                }
            }
            .alert(isPresented: $showAlert) { () -> Alert in
                Alert(
                    title: Text("Can't delete calendar"),
                    message: Text("You can't delete the default calendar.")
                )
            }
        }
    }
    
    func removeCalendar(at offsets: IndexSet) {
        for index in offsets.sorted().reversed() {
            
            let calendar = calendars[index]
            if(calendar.defaultCalendar != true){
                moc.delete(calendar)
            }else{
                showAlert = true
            }
    }
    try? moc.save()
    WidgetCenter.shared.reloadAllTimelines()

    }
}
