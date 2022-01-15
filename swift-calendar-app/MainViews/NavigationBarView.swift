//
//  NavigationBarView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 01.01.22.
//

import SwiftUI

struct NavigationBarView: View {
    @Binding var showMenu: Bool
    @Binding var showShowEvent: Bool
    @Binding var showAddEventSheet: Bool
    @Binding var showSearchView: Bool
    
    @State var title = "XXX"
    @State var fontSize = 20.0
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var currColorScheme: CurrentColorScheme
    
    var body: some View {
        HStack(){
            Button(action: {
                withAnimation{
                    self.showMenu.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(Color(currColorScheme))
                    .font(.system(size: fontSize))
            }.padding()
            Spacer()
            HStack{
                Text(title)
                    .font(.system(size: 20, weight: .heavy))
            }
            Spacer()
            Button(action: {self.showSearchView.toggle()}) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(currColorScheme))
                    .font(.system(size: fontSize))
            }.padding()
            Button(action: {self.showAddEventSheet.toggle()}) {
                Image(systemName: "plus")
                    .foregroundColor(Color(currColorScheme))
                    .font(.system(size: fontSize))
            }.padding()
        }
        .onAppear(){
            if(!isAppAlreadyLaunchedOnce()){
                let calendar = MCalendar(context: moc)
                calendar.key = UUID()
                calendar.name = "Default"
                calendar.color = "Yellow"
                calendar.defaultCalendar = true
                
                try? moc.save()
            }
        }
        Spacer()
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(showMenu: .constant(false), showShowEvent: .constant(false), showAddEventSheet: .constant(false), showSearchView: .constant(false), title: "Preview")
            .environmentObject(CurrentColorScheme(.blue))
    }
}
