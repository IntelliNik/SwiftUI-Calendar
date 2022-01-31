//
//  DateComponents.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 29.12.21.
//

import Foundation

public enum Weekday: CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

public func getNextOrPreviousDay(components: DateComponents, next: Bool) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    guard let nextDate = Calendar.current.date(byAdding: .day, value: next ? 1 : -1, to: date) else {return nil}
    return Calendar.current.dateComponents([.day, .weekday, .month, .year, .weekOfYear], from: nextDate)
}

public func getNextOrPreviousDate(components: DateComponents, next: Bool) -> Date?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    guard let nextDate = Calendar.current.date(byAdding: .day, value: next ? 1 : -1, to: date) else {return nil}
    return nextDate
}

public func getNextOrPreviousMonth(components: DateComponents, next: Bool) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    guard let nextDate = Calendar.current.date(byAdding: .month, value: next ? 1 : -1, to: date) else {return nil}
    return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: nextDate)
}

public func getNextOrPreviousYear(components: DateComponents, next: Bool) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    guard let nextDate = Calendar.current.date(byAdding: .year, value: next ? 1 : -1, to: date) else {return nil}
    return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: nextDate)
}

public func getNextOrPreviousWeek(components: DateComponents, next: Bool) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    guard let nextDate = Calendar.current.date(byAdding: .weekOfYear, value: next ? 1 : -1, to: date) else {return nil}
    return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: nextDate)
}

// Returns a DateComponent representing the choosen day in the week of the provided DateComponent
public func getDayInWeek(of components: DateComponents, day : Weekday) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    let weekday = transformWeekdayToGermanStandard(day: addWeekdayTo(components: components)!.weekday!)
    let resultDate : Date?
    switch day {
    case .monday:
        resultDate = Calendar.current.date(byAdding: .day, value: (-weekday+1), to: date)
    case .tuesday:
        resultDate = Calendar.current.date(byAdding: .day, value: (-weekday+2), to: date)
    case .wednesday:
        resultDate = Calendar.current.date(byAdding: .day, value: (-weekday+3), to: date)
    case .thursday:
        resultDate = Calendar.current.date(byAdding: .day, value: (-weekday+4), to: date)
    case .friday:
        resultDate = Calendar.current.date(byAdding: .day, value: (-weekday+5), to: date)
    case .saturday:
        resultDate = Calendar.current.date(byAdding: .day, value: (-weekday+6), to: date)
    case .sunday:
        resultDate = Calendar.current.date(byAdding: .day, value: (-weekday+7), to: date)
    }
    guard let result = resultDate else {return nil}
    return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: result)
}

// helper function to work with ints instead of enum
public func getDayInWeek(of components: DateComponents, day : Int) -> DateComponents?{
    switch day {
    case 1:
        return getDayInWeek(of: components, day: .monday)
    case 2:
        return getDayInWeek(of: components, day: .tuesday)
    case 3:
        return getDayInWeek(of: components, day: .wednesday)
    case 4:
        return getDayInWeek(of: components, day: .thursday)
    case 5:
        return getDayInWeek(of: components, day: .friday)
    case 6:
        return getDayInWeek(of: components, day: .saturday)
    case 7:
        return getDayInWeek(of: components, day: .sunday)
    default:
        return components
    }
}

// As in germany we start counting days on monday and that I am unwilling to subdue myself to another weird idiosyncracy
// of the US I convert this here by force assuming thet day is between 1 and 7
public func transformWeekdayToGermanStandard(day: Int) -> Int{
    if day >= 2 {
        return day - 1
    } else {
        // if the day is not 2 through 7 it must be Sunday and therefor the seventh day during which god rested as the bible says
        return 7
    }
}

public func addMonthToComponents(components: DateComponents, month: Int) -> DateComponents?{
    var newComponents = DateComponents()
    newComponents.month = month
    newComponents.year = components.year
    return newComponents
}

// Takes DateComponents and sets the weekday
public func addWeekdayTo(components: DateComponents) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear, .weekday], from: date)
}

enum PickerSelection{
    case current
    case previous
    case next
}
