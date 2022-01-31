//
//  EventView.swift
//  swift-calendar-app
//
//  Created by Mohammed, Farhadiba on 09.01.22.
//
//  File to create/display events

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
                            .font(.headline)
                            .lineLimit(1)
                        HStack{
                            Text(event.startdate!, style: .time)
                        }
                    }
                )
            
        }
    }
}



