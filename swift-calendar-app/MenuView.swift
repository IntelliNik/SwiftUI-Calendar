//
//  MenuView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 22.12.21.
//

import SwiftUI

struct MenuView: View {
    @State var colorSelection = Colors.pink
    @State var currentAccentColor = getAccentColor()
    
    @Binding var currentlySelectedView: ContainedView
    @State var currentlySelectedCalendar: Int = 0
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading) {
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .padding(.top, 20)
                        .padding()
                }
                Spacer()
                Button(action: {currentlySelectedView = .day}) {
                    Text("Day View")
                        .padding()
                        .border(currentlySelectedView == .day ? .white : .clear, width: 2)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .week}) {
                    Text("Week View")
                        .padding()
                        .border(currentlySelectedView == .week ? .white : .clear, width: 2)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .month}) {
                    Text("Month View")
                        .padding()
                        .border(currentlySelectedView == .month ? .white : .clear, width: 2)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .year}) {
                    Text("Year View")
                        .padding()
                        .border(currentlySelectedView == .year ? .white : .clear, width: 2)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .allEvents}) {
                    Text("All Events")
                        .padding()
                        .border(currentlySelectedView == .allEvents ? .white : .clear, width: 2)
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
            VStack(alignment: .leading) {
                Spacer()
                HStack{
                    Button(action: {currentlySelectedCalendar = 0}) {
                        Image(systemName: "square.fill")
                            .foregroundColor(.yellow)
                            .imageScale(.large)
                        Text("Calendar 1")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .padding()
                .border(currentlySelectedCalendar == 0 ? .white : .clear, width: 2)
                HStack{
                    Button(action: {currentlySelectedCalendar = 1}) {
                        Image(systemName: "square.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                        Text("Calendar 2")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .padding()
                .border(currentlySelectedCalendar == 1 ? .white : .clear, width: 2)
                HStack{
                    Button(action: {currentlySelectedCalendar = 2}) {
                        Image(systemName: "square.fill")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                        Text("Calendar 3")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .padding()
                .border(currentlySelectedCalendar == 2 ? .white : .clear, width: 2)
                Spacer()
            }
            VStack(alignment: .leading){
                Text("Color scheme")
                    .font(.headline)
                    .foregroundColor(.white)
                Picker(selection: $colorSelection, label: Text("Color Scheme")) {
                    ForEach(Colors.allCases, id: \.self) { color in
                        Image(systemName: color.image()).foregroundColor(.white)
                    }
                }
                .pickerStyle(.segmented)
                .foregroundColor(.white)
                .onChange(of: colorSelection){color in
                    var accentColor = ""
                    switch color {
                    case .pink:
                        accentColor = "AccentColorRed"
                    case .green:
                        accentColor = "AccentColorGreen"
                    case .blue:
                        accentColor = "AccentColorBlue"
                    }
                    setAccentColor(colorScheme: accentColor)
                    currentAccentColor = getAccentColor()
                }
                .padding()
                .colorMultiply(colorHelper(colorSelection))
            }
        }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(currentAccentColor))
            .edgesIgnoringSafeArea(.all)
    }
}

enum Colors: String, CaseIterable{
    case pink, green, blue
    
    func image() -> String {
        switch self.rawValue{
        case "pink":
            return "flame"
        case "green":
            return "leaf"
        default:
            return "drop"
        }
    }
}

func colorHelper(_ selected: Colors) -> Color {
    switch selected {
    case .pink:
        return .pink
    case .green:
        return .green
    case .blue:
        return .blue
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            HStack{
                MenuView(currentlySelectedView: .constant(.allEvents))
                    .frame(width: geometry.size.width/2)
                Text("")
                    .frame(width: geometry.size.width/2, height: geometry.size.height)
                    .background(.black)
            }
        }
    }
}
