//
//  DayViewTime.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 08.01.22.
//

import SwiftUI
struct DayViewTime: View {
    @Binding var dateComponents: DateComponents
    
    @State var eventsToday: FetchedResults<Event>
    
    @State var eventToShow: Event?
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    func filterEventsForHour(hour: Int) -> [Event]{
        var foundEvents: [Event] = []
        eventsToday.forEach{ event in
            if(Calendar.current.component(.hour, from: event.startdate!) == hour){
                foundEvents.append(event)
            }
        }
        return foundEvents
    }
    
    var body: some View {
        let cur_hour = getToday().hour
        let cur_day = getToday().day
        ScrollViewReader{ scroll in
            ScrollView(showsIndicators: false){
                ZStack{
                    VStack(alignment: .leading, spacing: 25){
                        ForEach(0...23, id:\.self){ hour in
                            GeometryReader{ geometry in
                                HStack{
                                    ZStack{
                                        Text("\(String(hour)):00")
                                            .padding([.top, .bottom]).frame(width: geometry.size.width * 0.2)
                                        if (cur_day == dateComponents.day){
                                            if (cur_hour == hour){
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(Color(getAccentColorString(from: colorScheme)), lineWidth: 2.0)
                                                    .frame(width: geometry.size.width * 0.175, height: 45)
                                            }
                                        }
                                    }
                                    ZStack{
                                        VStack(alignment: .leading){
                                            DayViewEachHour(eventsThisHour: filterEventsForHour(hour: hour))
                                        }.zIndex(1)
                                        Rectangle().fill(Color(UIColor.lightGray)).frame(height: 2).padding(.trailing, 30)
                                    }
                                }
                            }
                            Spacer().frame(height: 20)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}


//struct DayViewTime_Previews: PreviewProvider {
//    static var previews: some View {
//        DayViewTime(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)))
//    }
//}

