//
//  ColorHelper.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 04.01.22.
//

import SwiftUI
import MapKit

// Color
public let colorStrings = ["Yellow","Mint","Blue","Purple","Red","Orange","Brown","Indigo"]

func getColorFromString(stringColor: String?) -> Color{
    switch stringColor{
    case "Yellow": return .yellow
    case "Mint": return .mint
    case "Blue": return .blue
    case "Purple": return .purple
    case "Black": return .black
    case "Red": return .red
    case "Orange": return .orange
    case "Brown": return .brown
    case "Indigo": return .indigo
    default: return .gray
    }
}

func getRandomCalendarColor() -> String{
    return colorStrings.randomElement()!
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1
        )
    }
}

// helper function to translate the string representing the current color scheme
// as stored in UserDefaults to the string needed to initialize Color correctly
func getAccentColorString(from: String) -> String{
    switch from{
    case "red":
        return "AccentColorRed"
    case "green":
        return "AccentColorGreen"
    case "blue":
        return "AccentColorBlue"
    default:
        return "AccentColorRed"
    }
}

// this is now only used in the widgets
func getAccentColorString() -> String{
    let defaults = UserDefaults.standard
    
    switch defaults.string(forKey: "colorScheme"){
    case "red":
        return "AccentColorRed"
    case "green":
        return "AccentColorGreen"
    case "blue":
        return "AccentColorBlue"
    default:
        return "AccentColorRed"
    }
}

// Location
func getRegionFromDatabase(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) -> MKCoordinateRegion{
    return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
}



// Date
func getDateFromHours(hours: String) -> Date?{
    let hourFormatter = DateFormatter()
    hourFormatter.dateFormat = "HH:mm"
    return hourFormatter.date(from: hours)
}

func setMonth(dateComponents: DateComponents, month: Int) -> DateComponents{
    var newDateComponents = DateComponents()
    newDateComponents.year = dateComponents.year
    newDateComponents.month = month
    //set the DateComponent representing the month as the first day of this month
    newDateComponents.day = 1
    let tempDate = Calendar.current.date(from: newDateComponents)
    guard let unwrappedTempDate = tempDate
    else {
        print("setMonth didnt work, couldn't create tempDate, is nil")
        return newDateComponents
    }
    let resComponents = Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: unwrappedTempDate)
    return resComponents
}

func getBeginningOfDay(date: Date) -> Date{
    return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
}

func getEndOfDay(date: Date) -> Date{
    return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
}

func setYear(dateComponents: DateComponents, year: Int) -> DateComponents{
    var newDateComponents = DateComponents()
    newDateComponents.year = dateComponents.year
    return newDateComponents
}

func setDay(dateComponents: DateComponents, day: Int) -> DateComponents{
    var newDateComponents = DateComponents()
    newDateComponents.year = dateComponents.year
    newDateComponents.month = dateComponents.month
    newDateComponents.day = day
    return newDateComponents
}

func getToday() -> DateComponents{
    return Calendar.current.dateComponents([.hour, .day, .month, .year, .weekOfYear], from: Date.now)
}

public func getDateForStartdateComparison(from: DateComponents) -> Date?{
    var newComponents = from
    newComponents.hour = 23
    newComponents.minute = 59
    newComponents.second = 59
    return Calendar.current.date(from: newComponents)
}

public func getDateForEnddateComparison(from: DateComponents) -> Date?{
    var newComponents = from
    newComponents.hour = 0
    newComponents.minute = 0
    newComponents.second = 0
    return Calendar.current.date(from: newComponents)
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

let Months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


enum RepetitionInterval : String {
    case daily, weekly, monthly, yearly
}

let Month_short = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

let weekDay = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

let weekDayLong = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

let Hour = ["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00","07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "00:00"]

func addWeekday(dateComponents: DateComponents) -> DateComponents{
    let date = Calendar.current.date(from: dateComponents)
    var newDateComponents = DateComponents()
    newDateComponents.year = dateComponents.year
    newDateComponents.month = dateComponents.month
    newDateComponents.day = dateComponents.day
    newDateComponents.weekday = Calendar.current.component(.weekday, from: date!)
    return newDateComponents
}

func addWeekOfYear(dateComponents: DateComponents) -> DateComponents{
    let date = Calendar.current.date(from: dateComponents)
    var newDateComponents = DateComponents()
    newDateComponents.year = dateComponents.year
    newDateComponents.month = dateComponents.month
    newDateComponents.day = dateComponents.day
    newDateComponents.weekOfYear = Calendar.current.component(.weekOfYear, from: date!)
    return newDateComponents
}

func getCurrentWeekOfYear() -> Int{
    let dc = Calendar.current.dateComponents([.weekOfYear], from: Date.now)
    return dc.weekOfYear!
}

// URL

func getURLwithoutProtocol(urlString: String) -> String{
    if(urlString.hasPrefix("http://")){
        return String(urlString.dropFirst(7))
    }
    if(urlString.hasPrefix("https://")){
        return String(urlString.dropFirst(8))
    }
    return urlString
}

func getDayEventsFromForeverEvents(events: FetchedResults<ForeverEvent>, datecomponent: DateComponents) -> [ForeverEvent]{
    var eventsOfDate : [ForeverEvent] = []
    
    for event in events{
        switch event.repetitionInterval{
        case "Daily":
            guard let startdate = event.startdate else {return []}
            guard let curDate2 = Calendar.current.date(from: datecomponent) else {return []}
            var curDate = curDate2
            curDate.addTimeInterval(3600)
            if smallerEqualDateComp_Helper(startdate,curDate){
                eventsOfDate.append(event)
            }
            break
        case "Weekly":
            guard let startdate = event.startdate else {return []}
            guard let enddate = event.enddate else {return []}
            guard let curDate2 = Calendar.current.date(from: datecomponent) else {return []}
            var curDate = curDate2
            curDate.addTimeInterval(3600)
            var addEvent = false
            if smallerEqualDateComp_Helper(startdate,curDate) && smallerEqualDateComp_Helper(curDate,enddate){
                eventsOfDate.append(event)
            }else{
                Calendar.current.enumerateDates(startingAfter: startdate, matching: Calendar.current.dateComponents([.weekday], from: startdate) , matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward, using: {
                    (projStartdate, _, stop) in
                    if let projStartdate = projStartdate {
                        if smallerEqualDateComp_Helper(projStartdate, curDate)  {
                            let projEnddate = Date(timeInterval: getTimeInterval(between: startdate, and: enddate), since: projStartdate)
                            if smallerEqualDateComp_Helper(curDate, projEnddate) {
                                stop = true
                                addEvent = true
                            }
                        }
                        if !(smallerEqualDateComp_Helper(projStartdate, curDate)) {
                            stop = true
                            addEvent = false
                        }
                    } else {
                        stop = true
                        addEvent = false
                    }
                })
                    
                
                if addEvent {
                    eventsOfDate.append(event)
                }
            }
            break
        case "Monthly":
            guard let startdate = event.startdate else {return []}
            guard let enddate = event.enddate else {return []}
            guard let curDate2 = Calendar.current.date(from: datecomponent) else {return []}
            var curDate = curDate2
            curDate.addTimeInterval(3600)
            var addEvent = false
            if smallerEqualDateComp_Helper(startdate,curDate) && smallerEqualDateComp_Helper(curDate,enddate){
                eventsOfDate.append(event)
            }else{
                Calendar.current.enumerateDates(startingAfter: startdate, matching: Calendar.current.dateComponents([.day], from: startdate) , matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward, using: {
                    (projStartdate, _, stop) in
                    if let projStartdate = projStartdate {
                        if smallerEqualDateComp_Helper(projStartdate, curDate)  {
                            let projEnddate = Date(timeInterval: getTimeInterval(between: startdate, and: enddate), since: projStartdate)
                            if smallerEqualDateComp_Helper(curDate, projEnddate) {
                                stop = true
                                addEvent = true
                            }
                        }
                        if !(smallerEqualDateComp_Helper(projStartdate, curDate)) {
                            stop = true
                            addEvent = false
                        }
                    } else {
                        stop = true
                        addEvent = false
                    }
                })
                    
                
                if addEvent {
                    eventsOfDate.append(event)
                }
            }
            break
        case "Yearly":
            guard let startdate = event.startdate else {return []}
            guard let enddate = event.enddate else {return []}
            guard let curDate2 = Calendar.current.date(from: datecomponent) else {return []}
            var curDate = curDate2
            curDate.addTimeInterval(3600)
            var addEvent = false
            if smallerEqualDateComp_Helper(startdate,curDate) && smallerEqualDateComp_Helper(curDate,enddate){
                eventsOfDate.append(event)
            }else{
                Calendar.current.enumerateDates(startingAfter: startdate, matching: Calendar.current.dateComponents([.month,.day], from: startdate) , matchingPolicy: .strict, repeatedTimePolicy: .first, direction: .forward, using: {
                    (projStartdate, _, stop) in
                    if let projStartdate = projStartdate {
                        if smallerEqualDateComp_Helper(projStartdate, curDate)  {
                            let projEnddate = Date(timeInterval: getTimeInterval(between: startdate, and: enddate), since: projStartdate)
                            if smallerEqualDateComp_Helper(curDate, projEnddate) {
                                stop = true
                                addEvent = true
                            }
                        }
                        if !(smallerEqualDateComp_Helper(projStartdate, curDate)) {
                            stop = true
                            addEvent = false
                        }
                    } else {
                        stop = true
                        addEvent = false
                    }
                })
                    
                
                if addEvent {
                    eventsOfDate.append(event)
                }
            }
            break
        default:
            break
        }
    }
        
    return eventsOfDate
}

func getTimeInterval(between first: Date, and second: Date) -> TimeInterval {
    let minute: TimeInterval = 60.0
    let hour: TimeInterval = 60 * minute
    let day: TimeInterval = 24 * hour
    
    let diff = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: first, to: second)
    
    var interval: TimeInterval = 0.0
    interval = interval + Double(diff.day ?? 0) * day
    interval = interval + Double(diff.hour ?? 0) * hour
    interval = interval + Double(diff.minute ?? 0) * minute
    interval = interval + Double(diff.second ?? 0)
    
    return interval
}

func smallerEqualDateComp_Helper(_ first: Date, _ second: Date) -> Bool {
    switch Calendar.current.compare(first, to: second, toGranularity: .day) {
    case .orderedAscending:
        return true
    case .orderedSame:
        return true
    case .orderedDescending:
        return false
    }
}
