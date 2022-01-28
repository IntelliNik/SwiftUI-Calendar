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
    
    @State var expand = false
    @State var showText = true
    
    var body: some View {
        ZStack{
            Capsule()
                .fill(Color(getAccentColorString(from: colorScheme)))
                .frame(width: expand ? 1500 : 80, height: expand ? 1500 : 40)
            Text("Today")
                .foregroundColor(.white)
                .font(.custom("MyToday", size: 25))
                .fontWeight(.heavy)
                .opacity(showText ? 1 : 0)
        }
        .onTapGesture {
            showText = false
            withAnimation{
                expand = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, qos: .background) {
                dateComponents = getToday()
                withAnimation{
                    expand = false
                }
                showText = true
            }
        }
    }
}

struct TodayButton_Previews: PreviewProvider {
    static var previews: some View {
        TodayButton(dateComponents: .constant(DateComponents()))
    }
}
