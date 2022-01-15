//
//  TodayButton.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct TodayButton: View {
    @Binding var dateComponents: DateComponents

    var body: some View {
        Button(action: {
            let cur_date = Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)
            dateComponents = cur_date
        }, label: {
            Text("Today")
                .foregroundColor(.white)
                .font(.custom("MyToday", size: 25))
                .fontWeight(.heavy)
        })
        .frame(height: 40)
        .frame(maxWidth: 90)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(getAccentColorString()))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(Color(getAccentColorString()), lineWidth: 1)
        )
        
    }
}

struct TodayButton_Previews: PreviewProvider {
    static var previews: some View {
        TodayButton(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now))).previewInterfaceOrientation(.portrait)
    }
}
