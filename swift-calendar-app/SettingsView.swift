//
//  SettingsView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 26.12.21.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView{
            List{
                NavigationLink(destination: IconSelection()){
                    Text("Select App Icon")
                }
            }.navigationTitle("Settings")
        }
    }
}

struct IconSelection : View {
    enum Icon {
        case Icon1
        case Icon2
        case Icon3
    }
    
    @State var iconSelection: Icon = Icon.Icon1

    var body: some View {
        Picker("What is your favorite color?", selection: $iconSelection) {
            Image(systemName: "1.circle").tag(Icon.Icon1)
            Image(systemName: "2.circle").tag(Icon.Icon2)
            Image(systemName: "3.circle").tag(Icon.Icon3)
}
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
