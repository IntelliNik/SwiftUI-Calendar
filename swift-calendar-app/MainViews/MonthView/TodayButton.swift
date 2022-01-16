//
//  TodayButton.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI


struct TodayButton: View {
    @Binding var dateComponents: DateComponents
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        Button(action: {
            dateComponents = getToday()
        }, label: {
            Text("Today")
                .foregroundColor(.white)
                .font(.custom("MyToday", size: 25))
                .fontWeight(.heavy)
        })
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(getAccentColorString(from: colorScheme)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(Color(getAccentColorString(from: colorScheme)), lineWidth: 1)
        )
        
    }
}

struct TodayButton_Previews: PreviewProvider {
    static var previews: some View {
        TodayButton(dateComponents: .constant(DateComponents()))
    }
}
