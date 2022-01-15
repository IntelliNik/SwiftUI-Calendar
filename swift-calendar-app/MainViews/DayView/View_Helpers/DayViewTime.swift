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
        let cur_hour = getToday().hour
        //ScrollViewReader{ view in
            ScrollView{
                ZStack{
                    VStack(alignment: .leading, spacing: 25){
                        ForEach(0...23, id:\.self){ hour in
                            GeometryReader{ geometry in
                                HStack{
                                    ZStack{
                                        Text("\(String(hour)):00")
                                            .id(hour)
                                            .padding([.top, .bottom]).frame(width: geometry.size.width * 0.2)
                                        if (cur_hour == hour){
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color(getAccentColorString()), lineWidth: 2.0)
                                                .frame(width: 50, height: 45)
                                        }
                                    }
                                    ZStack{
                                        VStack(alignment: .leading){
                                            let eventsThisHour: [Event] = filterEventsForHour(hour: hour)
                                            ScrollView(.horizontal){
                                                HStack(){
                                                    ForEach(eventsThisHour, id:\.self){ event in
                                                        EventView(event: event).onTapGesture(){
                                                            eventToShow = event
                                                            showEventSheet = true
                                                        }
                                                    }
    //                                                if(eventsThisHour.count >= 1){
    //                                                    EventView(event: eventsThisHour[0]).onTapGesture(){
    //                                                        eventToShow = eventsThisHour[0]
    //                                                        showEventSheet = true
    //                                                    }
    //                                                }
    //                                                if(eventsThisHour.count >= 2){
    //                                                    EventView(event: eventsThisHour[1]).onTapGesture(){
    //                                                        eventToShow = eventsThisHour[1]
    //                                                        showEventSheet = true
    //                                                    }
    //                                                }
    //                                                if(eventsThisHour.count >= 3){
    //                                                    EventView(event: eventsThisHour[2]).onTapGesture(){
    //                                                        eventToShow = eventsThisHour[2]
    //                                                        showEventSheet = true
    //                                                    }
    //                                                }
    //                                                HStack{
    //                                                    if(eventsThisHour.count > 3){
    //                                                        Text("+\(eventsThisHour.count - 3)")
    //                                                            .font(.system(size: 12))
    //                                                            .padding()
    //                                                            .background(Circle()
    //                                                                            .fill(Color(getAccentColorString()))
    //                                                                            .frame(width: 30))
    //                                                        Spacer()
    //                                                    }
    //                                                }
    //                                                Spacer()
                                                }
                                            }.padding(.trailing, 45)
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
            //view.scrollTo(cur_hour)
        }
        
   // }
}


//struct DayViewTime_Previews: PreviewProvider {
//    static var previews: some View {
//        DayViewTime(dateComponents: .constant(Calendar.current.dateComponents([.weekday, .day, .month, .year], from: Date.now)))
//    }
//}
