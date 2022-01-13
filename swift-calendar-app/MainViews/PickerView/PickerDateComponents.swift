//
//  DateComponents.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 29.12.21.
//

import Foundation

public func getNextOrPreviousMonth(components: DateComponents, next: Bool) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    guard let nextDate = Calendar.current.date(byAdding: .month, value: next ? 1 : -1, to: date) else {return nil}
    return Calendar.current.dateComponents([.month, .year], from: nextDate)
}

public func getNextOrPreviousYear(components: DateComponents, next: Bool) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    guard let nextDate = Calendar.current.date(byAdding: .year, value: next ? 1 : -1, to: date) else {return nil}
    return Calendar.current.dateComponents([.year], from: nextDate)
}

public func getNextOrPreviousWeek(components: DateComponents, next: Bool) -> DateComponents?{
    guard let date = Calendar.current.date(from: components) else {return nil}
    guard let nextDate = Calendar.current.date(byAdding: .weekOfYear, value: next ? 1 : -1, to: date) else {return nil}
    return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: nextDate)
}

public func addMonthToComponents(components: DateComponents, month: Int) -> DateComponents?{
    var newComponents = DateComponents()
    newComponents.month = month
    newComponents.year = components.year
    return newComponents
}
