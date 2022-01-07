//
//  ColorHelper.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 04.01.22.
//

import SwiftUI
import MapKit

// Color
public let colorStrings = ["Yellow","Green","Blue","Pink","Purple","Black","Red","Orange","Brown","Cyan","Indigo"]

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
        case "Cyan": return .cyan
        case "Indigo": return .indigo
        default: return .gray
    }
}

func setAccentColor(colorScheme: String){
    let defaults = UserDefaults.standard
    defaults.set(colorScheme, forKey: "ColorScheme")
}

func getAccentColorString() -> String{
    let defaults = UserDefaults.standard
    return defaults.string(forKey: "ColorScheme") ?? "AccentColorRed"
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
    return newDateComponents
}
