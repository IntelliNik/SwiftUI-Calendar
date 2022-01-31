//
//  DailyOverviewView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 10.01.22.
//

import SwiftUI

struct SmallDailyOverviewView: View {
    @State var dateComponents: DateComponents
    
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
                Text(getWeekday()).padding([.top, .leading])
                    .foregroundColor(Color(getAccentColorString()))
                Spacer()
            }
            HStack{
                Text(Date.now, formatter: getDayFormatter()).padding(.leading)
                Spacer()
            }
            Spacer()
            VStack{
                if(foreverEventsToShow.count + eventsToday.count == 0){
                    Text("You have no events today.")
                }else if(foreverEventsToShow.count + eventsToday.count == 1){
                    Text("You have 1 event today.")
                } else if (foreverEventsToShow.count + eventsToday.count > 1){
                    Text("You have \(foreverEventsToShow.count + eventsToday.count) events today.")
                }
                Spacer()
            }.padding()
        }
        .onAppear(perform: {
            foreverEventsToShow = getDayEventsFromForeverEvents(events: foreverEvents, datecomponent: Calendar.current.dateComponents([.day,.month,.year,.weekday,.hour,.minute], from: Date.now))
        })
    }
}

func getDayFormatter() -> DateFormatter{
    let formatter = DateFormatter()
    formatter.dateFormat = "dd"
    return formatter
}

func getWeekday() -> String{
    let components = Calendar.current.dateComponents([.weekday], from: Date.now)
    switch components.weekday {
    case 1: return "Sunday"
    case 2: return "Monday"
    case 3: return "Tuesday"
    case 4: return "Wednesday"
    case 5: return "Thursday"
    case 6: return "Friday"
    case 7: return "Saturday"
    default: return ""
    }
}
