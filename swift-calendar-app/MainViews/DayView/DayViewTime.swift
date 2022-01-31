//
//  DayViewTime.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 08.01.22.
//
//  File to display the time lines and manage events

import SwiftUI
import WidgetKit
struct DayViewTime: View {
    @Binding var dateComponents: DateComponents
    @Binding var dateToShow: Date
    @FetchRequest var eventsToday: FetchedResults<Event>

    
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
    
    init(dateComponents: Binding<DateComponents>, dateToShow: Binding<Date>) {
        _dateComponents = dateComponents
        _dateToShow = dateToShow
        
        /*_eventsToday = FetchRequest<Event>(
            entity: Event.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
            ],
            predicate: NSPredicate(format: "startdate >= %@ && startdate <= %@", getBeginningOfDay(date: self._dateToShow.wrappedValue) as NSDate, getEndOfDay(date: self._dateToShow.wrappedValue) as NSDate)
        ) */
        
    _eventsToday = FetchRequest<Event>(
    sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ],
        // Forceunwrap might break!
    predicate: NSPredicate(format: "startdate <= %@ AND %@ <= enddate", getDateForStartdateComparison(from: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: self._dateToShow.wrappedValue) )! as CVarArg, getDateForEnddateComparison(from: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: self._dateToShow.wrappedValue ))! as CVarArg)
        )

    }
    
    var body: some View {
        ScrollView(showsIndicators: false){
            ScrollViewReader{ scroll in
                ZStack{
                    VStack(alignment: .leading, spacing: 25){
                        ForEach(0...23, id:\.self){ hour in
                            GeometryReader{ geometry in
                                HStack{
                                    ZStack{
                                        // Update font color according to appearance
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
                            }.id(hour)
                            Spacer().frame(height: 20)
                        }
                        Spacer()
                    }
                }// auto-scroll to current hour while on today's dayview
                .onChange(of: currentTime.components.hour) { value in
                    if currentTime.components.day == dateComponents.day{
                        if value ?? 0 <= 18{
                            withAnimation {
                                scroll.scrollTo(value ?? 0, anchor: .top)
                            }
                        }else{
                            withAnimation {
                                scroll.scrollTo(18, anchor: .top)
                            }
                        }
                    }
                }//scroll to current hour if today button was pressed
                .onChange(of: dateComponents.day) { value in
                    if currentTime.components.day == dateComponents.day{
                        if currentTime.components.hour ?? 0 <= 18 {
                            withAnimation {
                                scroll.scrollTo(currentTime.components.hour, anchor: .top)
                            }
                        }else{
                            withAnimation {
                                scroll.scrollTo(18, anchor: .top)
                            }
                        }
                    }
                }//initially scroll to current hour on view load
                .onAppear{
                    if currentTime.components.hour ?? 0 <= 18 {
                        withAnimation {
                            scroll.scrollTo(currentTime.components.hour, anchor: .top)
                        }
                    }else{
                        withAnimation {
                            scroll.scrollTo(18, anchor: .top)
                        }
                    }
                }
            }
        }
    }
}


