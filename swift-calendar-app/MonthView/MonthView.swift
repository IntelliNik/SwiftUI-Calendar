//
//  MonthView.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthView: View {
    //struct Month {
    //    var month : Int
    //    var year : Int
    //}
    var month: Int
    var year: Int
    let montlist = ["Januar", "Februar","March","April","May","June","July","August","September","October","November","December"]
    
    var body: some View {
        
            VStack {
                MonthViewMonthAndYear(month: montlist[month], year: year)
                Spacer()
                MonthViewCalendar()
                Spacer()
                Spacer()
                Spacer()
                
                Text("Here comes the rain!")
            }.padding() 
        
        
    }
}

struct MonthView_Previews: PreviewProvider {
    static var previews: some View {
        MonthView(month: 10, year: 2021)
    }
}
