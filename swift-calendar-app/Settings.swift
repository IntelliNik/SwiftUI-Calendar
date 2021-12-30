//
//  Settings.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 30.12.21.
//

import Foundation

func setAccentColor(colorScheme: String){
    let defaults = UserDefaults.standard
    defaults.set(colorScheme, forKey: "ColorScheme")
}

func getAccentColor() -> String{
    let defaults = UserDefaults.standard
    return defaults.string(forKey: "ColorScheme") ?? "AccentColorRed"
}
