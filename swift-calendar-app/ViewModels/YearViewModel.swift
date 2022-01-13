//
//  YearViewModel.swift
//  swift-calendar-app
//
//  Created by OE 310 on 11.01.22.
//

import Foundation

class YearViewModel: ObservableObject
{
    @Published var displayedYear: DateComponents?
    @Published var previousYear: DateComponents?
    @Published var nextYear: DateComponents?
    

    init() {
        initYears()
    }
    
    public func initYears(){
        self.displayedYear = Calendar.current.dateComponents([.day, .month, .year], from: Date.now)
        self.previousYear = getNextOrPreviousYear(components: (displayedYear)!, next: false)
        self.nextYear = getNextOrPreviousYear(components: (displayedYear)!, next: true)
    }
    
    public func moveForward(){
        self.previousYear = self.displayedYear
        self.displayedYear = self.nextYear
        self.nextYear = getNextOrPreviousYear(components: (displayedYear)!, next: true)
    }
    
    public func moveBackwards(){
        self.nextYear = self.displayedYear
        self.displayedYear = self.previousYear
        self.previousYear = getNextOrPreviousYear(components: (displayedYear)!, next: false)
    }

    public func getNextOrPreviousYear(components: DateComponents, next: Bool) -> DateComponents?{
        guard let date = Calendar.current.date(from: components) else {return nil}
        guard let nextDate = Calendar.current.date(byAdding: .year, value: next ? 1 : -1, to: date) else {return nil}
        return Calendar.current.dateComponents([.year], from: nextDate)
    }
}
