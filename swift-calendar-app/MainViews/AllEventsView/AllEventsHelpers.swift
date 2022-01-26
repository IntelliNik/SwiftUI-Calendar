//
//  AllEventsHelpers.swift
//  swift-calendar-app
//
//  Created by Lucas Wollenhaupt on 26.01.22.
//

import Foundation
import SwiftUI

func combine(_ events: FetchedResults<Event>, and fEvents: FetchedResults<ForeverEvent>) -> [AbstractEvent] {
    
    var eventIterator = 0
    var fEventIterator = 0
    var result: [AbstractEvent] = []
    
    // If one of the input arrays is empty return the other, this also means that
    // if both are empty an empty array is returned as intended
    /*
    if fEvents.isEmpty {
        return events as [AnyObject]
    }
    
    if events.isEmpty {
        return fEvents as [AnyObject]
    }
    */
     
    while eventIterator < events.count || fEventIterator < fEvents.count {
        // if one of the arrays is already completely added to result just add
        // the next element from the other and continue
        if eventIterator == events.count {
            result.append(fEvents[fEventIterator])
            fEventIterator += 1
            continue
        }
        if fEventIterator == fEvents.count {
            result.append(events[eventIterator])
            eventIterator += 1
            continue
        }
        
        // add the event which startdate is smaller
        if events[eventIterator].startdate ?? Date.distantFuture <= fEvents[fEventIterator].startdate ?? Date.distantFuture {
            result.append(events[eventIterator])
            eventIterator += 1
        } else {
            result.append(fEvents[fEventIterator])
            fEventIterator += 1
        }
    }
    
    return result
}

func finStr(_ n: Int) -> String {
    switch n {
    case 1:
        return "st"
    case 2:
        return "nd"
    default:
        return "th"
    }
}
