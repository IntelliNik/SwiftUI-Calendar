//
//  ColorHelper.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 04.01.22.
//

import SwiftUI

public let colorStrings = ["Yellow", "Green", "Red", "Blue", "Purple", "Orange", "Pink", "Cyan"]

func getColorFromString(stringColor: String) -> Color{
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
