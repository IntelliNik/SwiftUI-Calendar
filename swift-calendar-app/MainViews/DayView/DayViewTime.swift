//
//  DayViewTime.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 08.01.22.
//

import SwiftUI
struct DayViewTime: View {
    @Binding var dateComponents: DateComponents
    
    let eventsToday: FetchedResults<Event>
    let foreverEventsToday: [ForeverEvent]
    
    @State var eventToShow: Event?
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    @EnvironmentObject var currentTime: CurrentTime
    
    func filterEventsForHour(hour: Int) -> [Event]{
        var foundEvents: [Event] = []
        eventsToday.forEach{ event in
            if(Calendar.current.component(.hour, from: event.startdate!) == hour){
                foundEvents.append(event)
            }
        }
        return foundEvents
    }
    
    func filterForeverEventsForHour(hour: Int) -> [ForeverEvent] {
        var foundEvents: [ForeverEvent] = []
        foreverEventsToday.forEach{ event in
            if(Calendar.current.component(.hour, from: event.startdate!) == hour){
                foundEvents.append(event)
            }
        }
        return foundEvents
    }

    func merge(_ events: [Event], and fEvents: [ForeverEvent]) -> [AbstractEvent] {
        var eventIterator = 0
        var fEventIterator = 0
        var result: [AbstractEvent] = []
        
        while eventIterator < events.count || fEventIterator < fEvents.count {
            // if one of the arrays is already completely added to result just add
            // the next element from the other and continue
            if eventIterator == events.count {
                result.append(fEvents[fEventIterator])
                fEventIterator += 1
                continue
            }
            if fEventIterator == fEvents.count {
                result.append(events[eventIterator])
                eventIterator += 1
                continue
            }
            
            // add the event which startdate is smaller
            if events[eventIterator].startdate ?? Date.distantFuture <= fEvents[fEventIterator].startdate ?? Date.distantFuture {
                result.append(events[eventIterator])
                eventIterator += 1
            } else {
                result.append(fEvents[fEventIterator])
                fEventIterator += 1
            }
        }
        
        return result
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
                                        Text("\(String(hour)):00")
                                            .padding([.top, .bottom]).frame(width: geometry.size.width * 0.2)
                                            .foregroundColor((currentTime.components.day == dateComponents.day && currentTime.components.hour == hour) ? Color(getAccentColorString(from: colorScheme)) : .black)
                                    }
                                    ZStack{
                                        VStack(alignment: .leading){
                                            DayViewEachHour(eventsThisHour: merge(filterEventsForHour(hour: hour), and: filterForeverEventsForHour(hour: hour)))
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

