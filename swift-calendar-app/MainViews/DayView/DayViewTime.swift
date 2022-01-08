//
//  DayViewTime.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 08.01.22.
//

import SwiftUI
struct DayViewTime: View {
    @Binding var dateComponents: DateComponents

    var body: some View {
        ScrollView{
            ZStack{
                VStack(alignment: .leading, spacing: 25){
                    ForEach(0...23, id:\.self){
                        hour in
                        Spacer()
                        GeometryReader{ geometry in
                            HStack{
                                Text("\(String(hour)):00")
                                    .padding().frame(width: geometry.size.width * 0.2)
                                Rectangle().fill(Color(UIColor.lightGray)).frame(width: geometry.size.width * 0.7, height: 1.5)
                            }
                        }
                    }
                    Spacer()
                    GeometryReader {
                        geometry in
                        HStack{
                            Text("00:00").padding().frame(width: geometry.size.width * 0.2)
                            Rectangle().fill(Color(UIColor.lightGray)).frame(width: geometry.size.width * 0.7, height: 1.5)
                        }
                    }
                }
                
            }
        }
    }
}


struct DayViewTime_Previews: PreviewProvider {
    static var previews: some View {
        DayViewTime(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)))
    }
}
