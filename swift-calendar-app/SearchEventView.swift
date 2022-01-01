//
//  SearchEventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 01.01.22.
//

import SwiftUI

struct SearchEventView: View {
    @State var searchBarText: String = ""
    
    var body: some View {
        NavigationView{
            TextField("Search for events ...", text: $searchBarText).padding()
                .navigationTitle("Search for events")
            // TODO: display some events here, sorted by today
        }
    }
}

struct SearchEventView_Previews: PreviewProvider {
    static var previews: some View {
        SearchEventView()
    }
}
