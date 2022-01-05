//
//  ColorHelper.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 04.01.22.
//

import SwiftUI
import MapKit

// Color
public let colorStrings = ["Yellow", "Green", "Red", "Blue", "Purple", "Orange", "Pink", "Cyan"]

func getColorFromString(stringColor: String?) -> Color{
    switch stringColor{
    case "Yellow": return .yellow
    case "Green": return .green
    case "Red": return .red
    case "Blue": return .blue
    case "Purple": return .purple
    case "Orange": return .orange
    case "Pink": return .pink
    case "Cyan": return .cyan
    default: return .yellow
    }
}

func setAccentColor(colorScheme: String){
    let defaults = UserDefaults.standard
    defaults.set(colorScheme, forKey: "ColorScheme")
}

func getAccentColor() -> String{
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
    return hourFormatter.date(from: "08:00")
}
