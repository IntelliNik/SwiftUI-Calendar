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
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
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

struct CalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        DailyWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        DailyWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        DailyWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
