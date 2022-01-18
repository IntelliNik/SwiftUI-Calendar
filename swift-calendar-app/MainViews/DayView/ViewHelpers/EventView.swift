//
//  EventView.swift
//  swift-calendar-app
//
//  Created by Mohammed, Farhadiba on 09.01.22.
//

import SwiftUI

struct EventView: View {
    @State var event: Event
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(getColorFromString(stringColor: event.calendar?.color))
                .frame(width: 95, height: 65)
                .overlay(
            VStack{
                Text(event.name ?? "")
                        .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                HStack{
                    Text(event.startdate!, style: .time)
                        .font(.system(size: 12))
                }
            })
        }
    }
}

//struct EventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView()
//    }
//}


