//
//  MonthViewDayBox.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewDayBox: View {
    var date : Int //Todo: replace with actual day
    
    @State var width: CGFloat
    @State var length: CGFloat
    @State var fontSize: CGFloat?
    @State var rectangle: Bool?
    @State var markToday: Bool?
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: rectangle ?? false ? 3 : 10, style: .continuous)
                .stroke(.gray)
                .frame(width: width, height: length)
            RoundedRectangle(cornerRadius: rectangle ?? false ? 3 : 10, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: width, height: length)
                .overlay(Text(String(date))
                            .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                            .font(.system(size: fontSize ?? 20)))
        }
    }
}

struct MonthViewDayBox_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewDayBox(date: 1, width: 45, length: 45)
    }
}
