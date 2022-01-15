//
//  MonthViewDayBox.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewDayBox: View {
    var date : Int //Todo: replace with actual day
    
    var width, length: CGFloat?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.gray)
                .frame(width: self.width, height: self.length)
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: self.width, height: self.length)
                .overlay(Text(String(date)).foregroundColor(Color(getAccentColorString())))

        }
    }
}

struct MonthViewDayBox_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewDayBox(date: 1, width: 45, length: 45)
    }
}
