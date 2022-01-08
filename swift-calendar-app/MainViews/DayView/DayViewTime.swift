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
            VStack(alignment: .leading){

                ForEach(0...23, id:\.self){
                    hour in
                    Divider()
                    HStack{
                        Text("\(String(hour)):00")
                        .padding()
                    }
                    
                }
                Divider()
                Text("00:00").padding()
                Divider()
            }
        }
    }
}


struct DayViewTime_Previews: PreviewProvider {
    static var previews: some View {
        DayViewTime(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)))
    }
}
