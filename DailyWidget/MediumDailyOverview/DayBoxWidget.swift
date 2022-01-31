//
//  MonthViewDayBox.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct DayBoxWidget: View {
    var date : Int //Todo: replace with actual day
    
    var width: CGFloat
    var length: CGFloat
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(.gray)
                .frame(width: width, height: length)
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: width, height: length)
                .overlay(Text(String(date)))
                    .foregroundColor( .gray)
                .font(.system(size: 12))
        }
    }
}
