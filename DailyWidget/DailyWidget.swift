//
//  DailyWidget.swift
//  DailyWidget
//
//  Created by Schulte, Niklas on 08.01.22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        //Refresh at midnight to get the new data for the upcoming day.
        //Other refreshes happen
        let current_date = Date()
        let dayStart = Calendar.current.startOfDay(for: current_date)
        let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        
        let entry = SimpleEntry(date: dayStart)
        let timeline = Timeline(entries: [entry], policy: .after(dayEnd))
        completion(timeline)

    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct DailyWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    @StateObject private var dataController = DataController()

    var body: some View {
        if(widgetFamily == .systemSmall){
            SmallDailyOverviewView(dateComponents: Calendar.current.dateComponents([.day], from: Date.now))
                .environment(\.managedObjectContext, dataController.container.viewContext)
        } else if (widgetFamily == .systemMedium){
            MediumDailyOverviewView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        } else{
            LargeDailyOverviewView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}

@main
struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Overview")
        .description("This widget keeps you updated with your events today.")
    }
}
