//
//  LargeDailyOverviewView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 13.01.22.
//

import SwiftUI

struct LargeDailyOverviewView: View {
     
    @FetchRequest(entity: Event.entity(),
                 sortDescriptors: [
                    NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
                  ],
                  predicate: NSPredicate(format: "startdate >= %@ && startdate <= %@", getBeginningOfDay(date: Date.now) as NSDate, getEndOfDay(date: Date.now) as NSDate)) var eventsToday: FetchedResults<Event>
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var foreverEvents: FetchedResults<ForeverEvent>
    
    @State private var foreverEventsToShow: [ForeverEvent] = []
    
    var body: some View {
        VStack{
            HStack{
                Text("Your Events today").font(.headline)
                Spacer()
                Text(getWeekday())
                    .foregroundColor(Color(getAccentColorString()))
                Text(Date.now, formatter: getDayFormatter())
            }.padding()
            Spacer()
            ForEach(eventsToday, id:\.self){ event in
                HStack{
                    Text(event.name ?? "")
                    Spacer()
                    if let startDate = event.startdate{
                        Text(startDate, style: .time)
                    }
                }
                .padding()
                .background(getColorFromString(stringColor: event.calendar?.color))
            }
            ForEach(foreverEventsToShow, id:\.self){ event in
                HStack{
                    Text(event.name ?? "")
                    Spacer()
                    Image(systemName: "repeat")
                    if let startDate = event.startdate{
                        Text(startDate, style: .time)
                    }
                }
                .padding()
                .background(getColorFromString(stringColor: event.calendar?.color))
            }
        }
        .onAppear(perform: {
            foreverEventsToShow = getDayEventsFromForeverEvents(events: foreverEvents, datecomponent: Calendar.current.dateComponents([.day,.month,.year,.weekday,.hour,.minute], from: Date.now))
        })
    }
}

struct LargeDailyOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        LargeDailyOverviewView()
    }
}
