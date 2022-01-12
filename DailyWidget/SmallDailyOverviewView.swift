//
//  DailyOverviewView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 10.01.22.
//

import SwiftUI

struct SmallDailyOverviewView: View {
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Event.startdate, ascending: true),
        ]
    ) var events: FetchedResults<Event>
    
    var body: some View {
        HStack{
            Spacer()
            Text(Date.now, formatter: getDayFormatter()).padding([.top, .trailing])
        }
        HStack{
            Spacer()
            Text(getWeekday()).padding(.trailing)
        }
        Spacer()
        if(events.count == 0){
            Text("You have no events today.").padding()
        }else if(events.count == 1){
            Text("You have 1 event today.").padding()
        } else if (events.count > 1){
            Text("You have \(events.count) events today.").padding()
        }
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

struct SmallDailyOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        SmallDailyOverviewView()
    }
}
