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
    @EnvironmentObject var currentTime: CurrentTime
    @Environment(\.colorScheme) var darkMode
    
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
        ScrollViewReader{ scroll in
            ScrollView(showsIndicators: false){
                ZStack{
                    VStack(alignment: .leading, spacing: 25){
                        ForEach(0...23, id:\.self){ hour in
                            GeometryReader{ geometry in
                                HStack{
                                    ZStack{
                                        if darkMode == .light {
                                        Text("\(String(hour)):00")
                                            .padding([.top, .bottom]).frame(width: geometry.size.width * 0.2)
                                            .foregroundColor((currentTime.components.day == dateComponents.day && currentTime.components.hour == hour) ? Color(getAccentColorString(from: colorScheme)) : .black)
                                        } else {
                                            Text("\(String(hour)):00")
                                                .padding([.top, .bottom]).frame(width: geometry.size.width * 0.2)
                                                .foregroundColor((currentTime.components.day == dateComponents.day && currentTime.components.hour == hour) ? Color(getAccentColorString(from: colorScheme)) : .white)
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

