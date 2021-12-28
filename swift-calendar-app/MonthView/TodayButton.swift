//
//  TodayButton.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct TodayButton: View {
    var body: some View {
        let myRed = Color(red: 1.0, green: 0.8, blue: 0.8)
        Button(action: {
        }, label: {
            Text("Today")
                .foregroundColor(Color.red)
                .font(.custom("MyToday", size: 25))
                .fontWeight(.heavy)
        })
        .frame(height: 40)
        .frame(maxWidth: 90)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(myRed)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(myRed, lineWidth: 1)
        )
        
    }
}

struct TodayButton_Previews: PreviewProvider {
    static var previews: some View {
        TodayButton()
    }
}
