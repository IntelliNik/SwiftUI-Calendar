//
//  ShowEventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 01.01.22.
//

import SwiftUI

struct ShowEventView: View {
    @State var url: String
    
    var body: some View {
        NavigationView(){
            VStack{
            Text("URL: \(url)")
            // TODO: this preview can be used to visualize the link of an event
            MetadataView(vm: LinkViewModel(link: url))
                .padding()
                .frame(maxHeight: 400)
                .navigationTitle("Event: \"Apple Event\"")
            }
        }
    }
}

struct ShowEventView_Previews: PreviewProvider {
    static var previews: some View {
        ShowEventView(url: "https://apple.com")
    }
}
