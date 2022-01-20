//
//  CurrentTimePublisher.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 20.01.22.
//

import Foundation

class CurrentTime: ObservableObject {
    @Published var currentTime: DateComponents
    var timer: Timer
    
    init() {
        self.currentTime = Calendar.current.dateComponents([.year, .month, .day, .weekOfYear, .hour, .minute, .second], from: Date.now)
        
        let components = DateComponents(minute: 0, second: 0, nanosecond: 0)
        let triggerDate = Calendar.current.nextDate(after: Date.now.addingTimeInterval(3600), matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!
        
        self.timer = Timer()
        self.timer = Timer(fireAt: triggerDate, interval: 3600, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc private func updateTime() {
        self.currentTime = Calendar.current.dateComponents([.year, .month, .day, .weekOfYear, .hour, .minute, .second], from: Date.now)
        print("timer fired")
    }
    
    func test() -> Int {
        return 1
    }
}
