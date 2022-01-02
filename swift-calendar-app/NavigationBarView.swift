//
//  NavigationBarView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 01.01.22.
//

import SwiftUI

struct NavigationBarView: View {
    @Binding var showMenu: Bool
    @Binding var showAddEventSheet: Bool
    @Binding var showSearchView: Bool
    
    @State var fontSize = 20.0
    
    var body: some View {
        HStack(){
            Button(action: {self.showMenu.toggle()}) {
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(Color(getAccentColor()))
                    .font(.system(size: fontSize))
            }.padding()
            Spacer()
            Button(action: {self.showSearchView.toggle()}) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(getAccentColor()))
                    .font(.system(size: fontSize))
            }.padding()
            Button(action: {self.showAddEventSheet.toggle()}) {
                Image(systemName: "plus")
                    .foregroundColor(Color(getAccentColor()))
                    .font(.system(size: fontSize))
            }.padding()
        }
        Spacer()
    }
}

struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(showMenu: .constant(false), showAddEventSheet: .constant(false), showSearchView: .constant(false))
    }
}
