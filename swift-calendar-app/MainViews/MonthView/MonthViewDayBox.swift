//
//  MonthViewDayBox.swift
//  swift-calendar-app
//
//  Created by Din Ferizovic on 26.12.21.
//

import SwiftUI

struct MonthViewDayBox: View {

    @FetchRequest var eventsFetch: FetchedResults<Event>
    
    var date : Int
    var eventsOnDay: [Event] = []
        
    var width: CGFloat
    var length: CGFloat
    @State var fontSize: CGFloat? = nil
    @State var rectangle: Bool? = nil
    
    @EnvironmentObject var currentTime: CurrentTime
    @EnvironmentObject var viewModel: MonthViewModel
    @AppStorage("colorScheme") private var colorScheme = "red"

    init(displayedMonth: DateComponents, date: Int, width: CGFloat, length: CGFloat) {
        _eventsFetch = FetchRequest<Event>(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
            ],
            // Forceunwrap might break!
            predicate: NSPredicate(format: "startdate <= %@ AND %@ <= enddate", getDateForStartdateComparison(from: setDay(dateComponents: displayedMonth, day: date))! as CVarArg, getDateForEnddateComparison(from: setDay(dateComponents: displayedMonth, day: date))! as CVarArg)
            )
        
        self.date = date
        self.width = width
        self.length = length
    }
    
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
                        ForEach(Array(zip(eventsFetch.indices, eventsFetch)), id: \.0) { i, event in
                            if(i < 3){
                                Circle()
                                    .fill(getColorFromString(stringColor: event.calendar?.color))
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
        if eventsFetch.count == 0 {
            return false
        }
            
        else {
            return true
        }
    }
}
