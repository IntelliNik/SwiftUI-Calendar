//
//  ShowEventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 01.01.22.
//

import SwiftUI

struct ShowEventView: View {
    var body: some View {
        NavigationView(){
            // TODO: this preview can be used to visualize the link of an event
            MetadataView(vm: LinkViewModel(link: "https://apple.com"))
                .padding()
                .navigationTitle("Event: \"Apple Event\"")
        }
    }
}

struct ShowEventView_Previews: PreviewProvider {
    static var previews: some View {
        ShowEventView()
    }
}
