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
    
    @State var showEventSheet = false
    @State var eventToShow: Event?
    
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
        ScrollView{
            ZStack{
                VStack(alignment: .leading, spacing: 25){
                    ForEach(0...23, id:\.self){ hour in
                        GeometryReader{ geometry in
                            HStack{
                                Text("\(String(hour)):00")
                                    .padding([.top, .bottom]).frame(width: geometry.size.width * 0.2)
                                ZStack{
                                    VStack(alignment: .leading){
                                        let eventsThisHour: [Event] = filterEventsForHour(hour: hour)
                                        HStack(){
                                            if(eventsThisHour.count >= 1){
                                                EventView(event: eventsThisHour[0]).onTapGesture(){
                                                    eventToShow = eventsThisHour[0]
                                                    showEventSheet = true
                                                }
                                            }
                                            if(eventsThisHour.count >= 2){
                                                EventView(event: eventsThisHour[1]).onTapGesture(){
                                                    eventToShow = eventsThisHour[1]
                                                    showEventSheet = true
                                                }
                                            }
                                            if(eventsThisHour.count >= 3){
                                                EventView(event: eventsThisHour[2]).onTapGesture(){
                                                    eventToShow = eventsThisHour[2]
                                                    showEventSheet = true
                                                }
                                            }
                                            HStack{
                                                if(eventsThisHour.count > 3){
                                                    Text("+\(eventsThisHour.count - 3)")
                                                        .font(.system(size: 12))
                                                        .padding()
                                                        .background(Circle()
                                                                        .fill(Color(getAccentColorString()))
                                                                        .frame(width: 30))
                                                    Spacer()
                                                }
                                            }
                                            Spacer()
                                        }
                                    }.zIndex(1)
                                    Rectangle().fill(Color(UIColor.lightGray)).frame(height: 2).padding(.trailing, 30)
                                }
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }.sheet(isPresented: $showEventSheet){
            ShowEventView(event: eventToShow!)
        }
    }
}


//struct DayViewTime_Previews: PreviewProvider {
//    static var previews: some View {
//        DayViewTime(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)))
//    }
//}
