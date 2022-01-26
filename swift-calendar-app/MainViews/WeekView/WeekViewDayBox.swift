//
//  WeekViewDayBox.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 30.12.21.
//

import SwiftUI

let daylist = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

func isToday(from dateComponents: DateComponents, _ currentTime: CurrentTime) -> Bool {
    return dateComponents.year == currentTime.components.year && dateComponents.weekOfYear == currentTime.components.weekOfYear && dateComponents.day == currentTime.components.day
}

struct WeekViewDayBox: View {
    let dateComponents: DateComponents
    let todo: Bool
    let height: CGFloat
    let width: CGFloat
    
    var body: some View {
        
        ZStack {
            if todo {
                WeekViewRoundedRectangleBottomTodo(dateComponents: dateComponents, height: height, width: width)
                WeekViewRoundedRectangleTopTodo(height: height, width: width)
            } else {
                WeekViewRoundedRectangleTop(dateComponents: dateComponents, height: height, width: width)
                WeekViewRoundedRectangleBottom(dateComponents: dateComponents, height: height, width: width)
            }
        }
    }
}

struct WeekViewRoundedRectangleTop: View {
    let dateComponents: DateComponents
    let height: CGFloat
    let width: CGFloat
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    @EnvironmentObject var currentTime: CurrentTime
    @Environment(\.colorScheme) var darkMode
    
    var body: some View {
        ZStack {
            if darkMode == .dark {
                Rectangle()
                    .fill(.thinMaterial)
                    .colorInvert()
                    .colorMultiply((isToday(from: dateComponents, currentTime)) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                    .colorMultiply(Color(.sRGBLinear, red: 1 , green: 1, blue: 1, opacity: (isToday(from: dateComponents, currentTime)) ? 0.7 : 0.3))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .frame(width: width, height: 20)
                    .overlay(
                        HStack{
                            Text("  \(daylist[transformWeekdayToGermanStandard(day: dateComponents.weekday ?? 1) - 1])").fontWeight(.heavy)
                            Spacer()
                            Text("\(Calendar.current.date(from: dateComponents)!.formatted(.dateTime.day().month()))  ").fontWeight(.heavy)
                        })
                    .offset(x:0 , y: -((height - 20)/2))
                    .foregroundColor(.gray)
            } else {
                Rectangle()
                    .fill(.thinMaterial)
                    .colorMultiply((isToday(from: dateComponents, currentTime)) ? Color(getAccentColorString(from: colorScheme)) : .gray)
                    .colorMultiply(Color(.sRGBLinear, red: 1 , green: 1, blue: 1, opacity: 0.3))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .frame(width: width, height: 20)
                    .overlay(
                        HStack{
                            Text("  \(daylist[transformWeekdayToGermanStandard(day: dateComponents.weekday ?? 1) - 1])").fontWeight(.heavy)
                            Spacer()
                            Text("\(Calendar.current.date(from: dateComponents)!.formatted(.dateTime.day().month()))  ").fontWeight(.heavy)
                        })
                    .offset(x:0 , y: -((height - 20)/2))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct WeekViewRoundedRectangleBottom: View {
    let dateComponents: DateComponents
    let height: CGFloat
    let width: CGFloat
    
    //@FetchRequest var foreverEvents: FetchedResults<ForeverEvent>
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var foreverEvents: FetchedResults<ForeverEvent>
    
    @State private var foreverEventsToShow: [ForeverEvent] = []
    
    var body: some View {
        ZStack {
            // Fore unwrap here might not be the best idea
            WeekEventView(filter: dateComponents, foreverEventsToShow: foreverEventsToShow)
                .frame(width: width - 5, height: height - 30, alignment: .top)
                .offset(x: 0, y: 10)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.gray)
                .frame(width: width, height: height)
            
            Rectangle()
                .foregroundColor(.gray)
                .frame(width: width, height: 1)
                .offset(x:0 , y: -((height - 20)/2) + 10)
        }
        .onChange(of: dateComponents) { newvalue in
            foreverEventsToShow = getDayEventsFromForeverEvents(events: foreverEvents, datecomponent: newvalue)
                }
        .onChange(of: foreverEvents.count) { _ in
            foreverEventsToShow = getDayEventsFromForeverEvents(events: foreverEvents, datecomponent: dateComponents)
                }
        .onAppear(perform: {
            foreverEventsToShow = getDayEventsFromForeverEvents(events: foreverEvents, datecomponent: dateComponents)
        })
    }
}

struct WeekViewRoundedRectangleTopTodo: View {
    let height: CGFloat
    let width: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: width, height: 10)
                .offset(x:0 , y: -((height - 20)/2) + 5)
                .foregroundColor(.gray)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.thinMaterial)
                .frame(width: width, height: 20)
                .overlay(Text("todo").fontWeight(.heavy))
                .offset(x:0 , y: -((height - 20)/2))
                .foregroundColor(.gray)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundColor(.gray)
                .frame(width: width, height: 1)
                .offset(x:0 , y: -((height - 20)/2) + 10)
        }
    }
}

struct WeekViewRoundedRectangleBottomTodo: View {
    let dateComponents: DateComponents
    let height: CGFloat
    let width: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.gray)
                .frame(width: width, height: height)
        }
    }
}

struct WeekViewDayBox_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeekViewDayBox(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now), todo: false, height: 220, width: 220)
            ZStack {
                WeekViewRoundedRectangleBottomTodo(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now), height: 220, width: 220)
                WeekViewRoundedRectangleTopTodo(height: 220, width: 220)
            }
            WeekViewRoundedRectangleTop(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now) , height: 220, width: 220)
            WeekViewRoundedRectangleBottom(dateComponents: Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: Date.now), height: 220, width: 220)
        }
        .preferredColorScheme(.dark)
        .environmentObject(CurrentTime())
    }
}
