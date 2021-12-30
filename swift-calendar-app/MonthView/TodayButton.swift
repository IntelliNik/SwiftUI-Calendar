//
//  TodayButton.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct TodayButton: View {
    var body: some View {
        Button(action: {
        }, label: {
            Text("Today")
                .foregroundColor(.white)
                .font(.custom("MyToday", size: 25))
                .fontWeight(.heavy)
        })
        .frame(height: 40)
        .frame(maxWidth: 90)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(getAccentColor()))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(Color(getAccentColor()), lineWidth: 1)
        )
        
    }
}

struct TodayButton_Previews: PreviewProvider {
    static var previews: some View {
        TodayButton()
    }
}
