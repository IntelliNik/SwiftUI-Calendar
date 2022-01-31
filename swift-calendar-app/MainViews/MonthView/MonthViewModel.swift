//
//  MonthViewModel.swift
//  swift-calendar-app
//
//  Created by OE 310 on 14.01.22.
//

import Foundation
import SwiftUI
import CoreData

class MonthViewModel: ObservableObject
{
    
    //the three months displayed in the picker
    @Published var displayedMonth: DateComponents?
    @Published var previousMonth: DateComponents?
    @Published var nextMonth: DateComponents?
    
    //the start day and the end day of the displayedMonth
    @Published var startDayOfMonth: DateComponents?
    @Published var endDayOfMonth: DateComponents?
        
    //array that is responsible for the calendar visualization of a month
    //includes strings of all days in a month
    //furhtermore includes all the days from monday to the weekday of the first day of the month as nils
    //example: January 2022 -> (nil,nil,nil,nil,nil,1,2,3,4,...,31)
    //we thus no 1.1.22 is a saturday
    var daysOfMonth = [String?]()
    var daysOfMonthWithWeek = [String?]()
    
    init(dateComponents: DateComponents){
        initMonths(dateComponents: dateComponents)
    }
    
    public func initMonths(dateComponents: DateComponents){
        self.displayedMonth = Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Calendar.current.date(from :dateComponents)!)
        self.previousMonth = self.getNextOrPreviousMonth(components: (displayedMonth)!, next: false)
        self.nextMonth = self.getNextOrPreviousMonth(components: (displayedMonth)!, next: true)
        
        calcDaysOfMonth()
    }
    
    public func calcDaysOfMonth(){
        //initialize helper variables
        self.startDayOfMonth = startOfMonth(dateComponents: displayedMonth!)
        self.endDayOfMonth = endOfMonth(dateComponents: displayedMonth!)
        
        self.daysOfMonth = [String?]()
        self.daysOfMonthWithWeek  = [String?]()
        
        //we need too transform the weekday component so monday is mapped to 1 instead of sunday
        let transformedStartWeekday = transformWeekdays(date: Calendar.current.date(from: startDayOfMonth!)!)
        
        //append starting week and nil
        daysOfMonthWithWeek.append("W\(self.startDayOfMonth?.weekOfYear ?? 0)")

        //put in nils so the view is filled accordingly
        if(transformedStartWeekday != 1){
            for _ in 1...(transformedStartWeekday! - 1) {
                daysOfMonth.append(nil)
                daysOfMonthWithWeek.append(nil)
            }
        }
        
        //this var of type DateComponents will be used to iterate per day through the (to be) displayedMonth
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
    
    //returns the first day of the provided month as datecomponents
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
    
    //returns the last day of the provided month as datecomponents
    func endOfMonth(dateComponents: DateComponents) -> DateComponents? {
        let endDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: Calendar.current.date(from: startOfMonth(dateComponents: dateComponents)!)!)
        return Calendar.current.dateComponents([.calendar, .timeZone,
                                                .era, .quarter,
                                                .year, .month, .day,
                                                .hour, .minute, .second, .nanosecond,
                                                .weekday, .weekdayOrdinal,
                                                .weekOfMonth, .weekOfYear, .yearForWeekOfYear], from: endDate!)
    }
    
    //transforms the weekdays into german calendar standard to start with monday
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

