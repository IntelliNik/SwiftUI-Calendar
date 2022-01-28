//
//  MonthViewDayBox.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewDayBox: View {
    var date : Int //Todo: replace with actual day
    var eventsOnDay: [String?]
    
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
            VStack(spacing: 2){
                Text(String(date))
                    .font(.system(size: fontSize ?? 20))
                    .foregroundColor((viewModel.displayedMonth?.month == currentTime.components.month && date == currentTime.components.day) ? Color(getAccentColorString(from: colorScheme)) : .gray)
            
                //HStack should mark up to 3 events
                if isVisible() {
                    HStack(spacing: 5){
                        ForEach(eventsOnDay.indices, id: \.self) { i in
                            if(eventsOnDay[i] == nil){
                                //do nothing
                            }
                            else{
                                Circle()
                                    .fill(getColorFromString(stringColor: eventsOnDay[i]))
                                    .frame(width: 7, height: 7)
                            }
            
                        }
                    }
                        .frame(minHeight: 7, maxHeight: 7)
                }
            }
        }
    }
            
    func isVisible() -> Bool{
        if eventsOnDay.count == 0 {
            return false
        }
            
        else {
            return true
        }
    }
}

/*struct MonthViewDayBox_Previews: PreviewProvider {
    static var previews: some View {
        MonthViewDayBox(date: 1, width: 45, length: 45)
    }
}*/
