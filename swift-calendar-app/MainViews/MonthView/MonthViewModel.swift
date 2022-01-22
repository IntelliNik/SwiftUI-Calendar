//
//  MonthViewModel.swift
//  swift-calendar-app
//
//  Created by OE 310 on 14.01.22.
//

import Foundation

class MonthViewModel: ObservableObject
{
    @Published var displayedMonth: DateComponents?
    @Published var previousMonth: DateComponents?
    @Published var nextMonth: DateComponents?
    
    private var startDayOfMonth: DateComponents?
    private var endDayOfMonth: DateComponents?
    
    @Published var daysOfMonth = [String?]()
    @Published var daysOfMonthWithWeek = [String?]()

    init(dateComponents: DateComponents) {
        initMonths(dateComponents: dateComponents)
    }
    
    public func initMonths(dateComponents: DateComponents){
        self.displayedMonth = Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Calendar.current.date(from :dateComponents)!)
        self.previousMonth = self.getNextOrPreviousMonth(components: (displayedMonth)!, next: false)
        self.nextMonth = self.getNextOrPreviousMonth(components: (displayedMonth)!, next: true)
        
        calcDaysOfMonth()
    }
    
    public func calcDaysOfMonth(){
        self.startDayOfMonth = startOfMonth(dateComponents: displayedMonth!)
        self.endDayOfMonth = endOfMonth(dateComponents: displayedMonth!)
        
        self.daysOfMonth = [String?]()
        //we need too transform the weekday component so monday is mapped to 1 instead of sunday
        let transformedStartWeekday = transformWeekdays(date: Calendar.current.date(from: startDayOfMonth!)!)
        
        daysOfMonthWithWeek.append("W\(self.startDayOfMonth?.weekOfYear ?? 0)")
        
        //put in nils so the view is filled accordingly
        if(transformedStartWeekday != 1){
            for _ in 1...(transformedStartWeekday! - 1) {
                daysOfMonth.append(nil)
                daysOfMonthWithWeek.append(nil)
            }
        }
        
        var iterateDay = startDayOfMonth
        var lastWeekOfYear = self.startDayOfMonth?.weekOfYear
        
        for index in 1...(endDayOfMonth?.day)! {
            daysOfMonth.append( "\(index)" )
            
            if lastWeekOfYear != iterateDay?.weekOfYear {
                lastWeekOfYear = iterateDay?.weekOfYear
                daysOfMonthWithWeek.append("W\(lastWeekOfYear ?? 0)")
            }
            daysOfMonthWithWeek.append( "\(index)" )
            iterateDay = getNextDay(components: iterateDay!)
        }
    }
    
    public func moveForward(){
        self.previousMonth = self.displayedMonth
        self.displayedMonth = self.nextMonth
        self.nextMonth = self.getNextOrPreviousMonth(components: (displayedMonth)!, next: true)
        
        
        calcDaysOfMonth()
    }
    
    public func moveBackwards(){
        self.nextMonth = self.displayedMonth
        self.displayedMonth = self.previousMonth
        self.previousMonth = self.getNextOrPreviousMonth(components: (displayedMonth)!, next: false)
        
        calcDaysOfMonth()
    }

    public func getNextOrPreviousMonth(components: DateComponents, next: Bool) -> DateComponents?{
        guard let date = Calendar.current.date(from: components) else {return nil}
        guard let nextDate = Calendar.current.date(byAdding: .month, value: next ? 1 : -1, to: date) else {return nil}
        return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: nextDate)
    }
    
    public func getNextDay(components: DateComponents) -> DateComponents?{
        guard let date = Calendar.current.date(from: components) else {return nil}
        guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else {return nil}
        return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: nextDate)
    }
    
    //
    func startOfMonth(dateComponents: DateComponents) -> DateComponents? {
        guard let date = Calendar.current.date(from: dateComponents) else {return nil}
        let startDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: date)))!
        return Calendar.current.dateComponents([.calendar, .timeZone,
                                                .era, .quarter,
                                                .year, .month, .day,
                                                .hour, .minute, .second, .nanosecond,
                                                .weekday, .weekdayOrdinal,
                                                .weekOfMonth, .weekOfYear, .yearForWeekOfYear], from: startDate)
    }
    
    //
    func endOfMonth(dateComponents: DateComponents) -> DateComponents? {
        let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: Calendar.current.date(from: startOfMonth(dateComponents: dateComponents)!)!)
        return Calendar.current.dateComponents([.calendar, .timeZone,
                                                .era, .quarter,
                                                .year, .month, .day,
                                                .hour, .minute, .second, .nanosecond,
                                                .weekday, .weekdayOrdinal,
                                                .weekOfMonth, .weekOfYear, .yearForWeekOfYear], from: endDate!)
    }
    
    func transformWeekdays(date: Date) -> Int?{
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        
        if (dayOfWeek > 1){
            return dayOfWeek - 1
        }
        
        else {
            return 7
        }
    }
}
