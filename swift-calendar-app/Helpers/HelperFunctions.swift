//
//  ColorHelper.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 04.01.22.
//

import SwiftUI
import MapKit

// Color
public let colorStrings = ["Yellow","Green","Blue","Pink","Purple","Black","Red","Orange","Brown","Indigo"]

func getColorFromString(stringColor: String?) -> Color{
    switch stringColor{
    case "Yellow": return .yellow
    case "Green": return .green
    case "Blue": return .blue
    case "Pink": return .pink
    case "Purple": return .purple
    case "Black": return .black
    case "Red": return .red
    case "Orange": return .orange
    case "Brown": return .brown
    case "Indigo": return .indigo
    default: return .gray
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

func getToday() -> DateComponents{
    return Calendar.current.dateComponents([.day, .month, .year, .weekOfYear], from: Date.now)
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
