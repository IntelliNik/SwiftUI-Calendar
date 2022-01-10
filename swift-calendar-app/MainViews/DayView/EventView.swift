//
//  EventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 09.01.22.
//

import SwiftUI

struct EventView: View {
    @State var event: Event
    
    var body: some View {
        HStack{
            VStack{
                Text(event.name ?? "")
                    .font(.system(size: 14))
                Spacer()
                Text(event.startdate!, style: .time)
                    .font(.system(size: 14))
            }
            .padding()
            .background(.yellow)
        }.zIndex(1)
    }
}

//struct EventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView()
//    }
//}
