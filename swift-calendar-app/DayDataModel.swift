//
//  ContentDataSource.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 19.12.21.
//

import SwiftUI
import Combine

struct IdentifyableDay: Identifiable {
    let id = UUID()
    let dateComponents: DateComponents
    let date: Date?
    
    init(dateComponents: DateComponents) {
        self.dateComponents = dateComponents
        if let date = Calendar.current.date(from: self.dateComponents){
            self.date = date
        }else {
            self.date = nil
        }
    }
}

class DayDataModel: ObservableObject {
    @Published var items = [IdentifyableDay]()
    @Published var isLoadingPage = false
    
    let chuckSize = 100
    
    init() {
        var currentDate = getDateComponentsDay(date: Date.now)
        var daysBefore: [IdentifyableDay] = []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let theHolyDate = formatter.date(from: "1970/01/01")
        
        while Calendar.current.date(from: currentDate)! > theHolyDate!{
            if let nextDate = getDateComponentsDayBefore(components: currentDate){
                daysBefore.append(IdentifyableDay(dateComponents: nextDate))
                currentDate = nextDate
            }
        }
        items += daysBefore.reversed()
        
        let todayComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date.now)
        items.append(IdentifyableDay(dateComponents: todayComponents))
        
        currentDate = getDateComponentsDay(date: Date.now)
        for _ in 1...chuckSize{
            if let nextDate = getDateComponentsDayAfter(components: currentDate){
                items.append(IdentifyableDay(dateComponents: nextDate))
                currentDate = nextDate
            }
        }
        
        loadMoreContent(chunkSize: chuckSize)
    }
    
    func getDateComponentsDay(date: Date) -> DateComponents{
        return Calendar.current.dateComponents([.day, .month, .year], from: date)
    }
    
    func getDateComponentsDayAfter(components: DateComponents) -> DateComponents? {
        if let date = Calendar.current.date(from: components){
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date){
                return getDateComponentsDay(date: tomorrow)
            }
        }
        return nil
    }
    
    func getDateComponentsDayBefore(components: DateComponents) -> DateComponents? {
        if let date = Calendar.current.date(from: components){
            if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date){
                return getDateComponentsDay(date: yesterday)
            }
        }
        return nil
    }
    
    func getIdentifyableToday() -> IdentifyableDay? {
        for item in items {
            let todayComponents = getDateComponentsDay(date: Date.now)
            if item.dateComponents == todayComponents {
                return item
            }
        }
        return nil
    }
    
    
    func loadMoreContentIfNeeded(currentDate myDate: IdentifyableDay?) {
        guard let myDate = myDate else {
            loadMoreContent(chunkSize: chuckSize)
            return
        }
        
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.dateComponents == myDate.dateComponents }) == thresholdIndex {
            loadMoreContent(chunkSize: chuckSize)
        }
    }
    
    private func loadMoreContent(chunkSize: Int) {
        guard !isLoadingPage else {
            return
        }
        
        isLoadingPage = true
        
        /*
         for x in 1...chunkSize{
         items.append(Calendar.current.date(byAdding: .day, value: -chunkSize+x, to: currentlyLast ?? Date.now) ?? Date.now)
         }
         */
        
        guard var currentDate = items.last?.dateComponents else {return}
        
        for _ in 1...chunkSize{
            if let nextDate = getDateComponentsDayAfter(components: currentDate){
                items.append(IdentifyableDay(dateComponents: nextDate))
                currentDate = nextDate
            }
        }
        
        isLoadingPage = false
    }
}
