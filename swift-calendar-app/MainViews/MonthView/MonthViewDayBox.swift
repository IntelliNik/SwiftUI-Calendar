//
//  MonthViewDayBox.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewDayBox: View {
    var date : Int //Todo: replace with actual day
    
    var width: CGFloat
    var length: CGFloat
    @State var fontSize: CGFloat? = nil
    @State var rectangle: Bool? = nil
    
    @EnvironmentObject var currentTime: CurrentTime
    @EnvironmentObject var viewModel: MonthViewModel
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
                            .foregroundColor((viewModel.displayedMonth?.year == currentTime.components.year && viewModel.displayedMonth?.month == currentTime.components.month && date == currentTime.components.day) ? Color(getAccentColorString(from: colorScheme)) : .gray))
                .font(.system(size: fontSize ?? 20))
        }
    }
}

struct MonthViewDayBox_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewDayBox(date: 1, width: 45, length: 45)
    }
}
