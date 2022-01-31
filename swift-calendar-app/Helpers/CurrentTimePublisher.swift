//
//  CurrentTimePublisher.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 20.01.22.
//
// This class publishes the current time as DateComponents. It updates this time
// at every full hour. As timers can get invalidated when the app is suspended
// CurrentTime offers functions to reset the timer when entering foreground
// and invalidate it manually when entering background.

import Foundation

class CurrentTime: ObservableObject {
    @Published var components: DateComponents
    var timer: Timer?
    
    // Initialize components with the current time and set a timer
    init() {
        self.components = Calendar.current.dateComponents([.year, .month, .day, .weekOfYear, .hour, .minute, .second], from: Date.now)
        self.timer = Timer()
        self.timer = CurrentTime.getTimer(withTarget: self)
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    
    // This function is triggered by the timer. It updates components to the current time
    @objc private func updateTime() {
        self.components = Calendar.current.dateComponents([.year, .month, .day, .weekOfYear, .hour, .minute, .second], from: Date.now)
        print("timer fired")
        print("Minute:\(self.components.minute)")
        print("Hour:\(self.components.hour)")
    }
    
    // This function should be called when the current Scene enters background. It invalidates the timer.
    func enterBackground() {
        timer!.invalidate()
        self.timer = nil
        print("invalidated timer")
    }
    
    // This function must be called when the Scene enters foreground to ensure that components is set at the next full hour.
    // It sets components immediately to make sure it is up to date and then sets a new timer.
    func activate() {
        self.components = Calendar.current.dateComponents([.year, .month, .day, .weekOfYear, .hour, .minute, .second], from: Date.now)
        self.timer = CurrentTime.getTimer(withTarget: self)
        RunLoop.main.add(self.timer!, forMode: .common)
        
        print("activated CurrentTime")
    }
    
    // This function is used in activate() and init(). It calculates the time passed since the last full hour in seconds. Then it returns a timer
    // set to trigger the first time at the next full hour and each hour after that.
    static private func getTimer(withTarget target: CurrentTime) -> Timer {
        let currentTime = Calendar.current.dateComponents([.year, .month, .day, .weekOfYear, .hour, .minute, .second], from: Date.now)
        let diff = Calendar.current.dateComponents([.second], from: Date.now, to: Calendar.current.date(bySettingHour: currentTime.hour!, minute: 0, second: 0, of: Date.now, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)!)

        return Timer(fireAt: Date.now.addingTimeInterval(3600 + Double(diff.second!)), interval: 3600, target: target, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
}
