//
//  MenuView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 22.12.21.
//

import SwiftUI

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

enum MenuSelection{
    case day
    case week
    case month
    case year
    case allEvents
}

struct MenuView: View {
    @State private var colorScheme: Colors = Colors.pink
    
    @State var currentlySelectedMenuItem: MenuSelection = MenuSelection.allEvents
    @State var currentlySelectedCalendar: Int = 0
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
                VStack(alignment: .leading) {
                    NavigationLink(destination: SettingsView()){
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .imageScale(.large)
                            .padding(.top, 40)
                    }
                    Spacer()
                    Button(action: {currentlySelectedMenuItem = MenuSelection.day}) {
                        Text("Day View")
                            .padding()
                            .border(currentlySelectedMenuItem == MenuSelection.day ? .white : .clear, width: 2)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    Button(action: {currentlySelectedMenuItem = MenuSelection.week}) {
                        Text("Week View")
                            .padding()
                            .border(currentlySelectedMenuItem == MenuSelection.week ? .white : .clear, width: 2)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    Button(action: {currentlySelectedMenuItem = MenuSelection.month}) {
                        Text("Month View")
                            .padding()
                            .border(currentlySelectedMenuItem == MenuSelection.month ? .white : .clear, width: 2)
                            .foregroundColor(.white)
                            .font(.headline)
                        NavigationLink(destination:
                                        MonthView(month:11,year: 2021)
                        ){
                        Text("   " + String(2021) + "   " )
                            .font(.system(size: 17, weight: .bold, design: .default))
                        }
                    }
                    Button(action: {currentlySelectedMenuItem = MenuSelection.year}) {
                        Text("Year View")
                            .padding()
                            .border(currentlySelectedMenuItem == MenuSelection.year ? .white : .clear, width: 2)
                            .foregroundColor(.white)
                            .font(.headline)
                        NavigationLink(destination:
                            YearView(year:2021)
                        ){
                        Text("   " + String(2021) + "   " )
                            .font(.system(size: 17, weight: .bold, design: .default))
                        }
                    }
                    Button(action: {currentlySelectedMenuItem = MenuSelection.allEvents}) {
                        Text("All Events")
                            .padding()
                            .border(currentlySelectedMenuItem == MenuSelection.allEvents ? .white : .clear, width: 2)
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
                    Picker(selection: $colorScheme, label: Text("Color Scheme")) {
                        ForEach(Colors.allCases, id: \.self) { color in
                            Image(systemName: color.image()).foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.segmented)
                    .foregroundColor(.white)
                    .padding([.bottom, .leading, .trailing])
                    .colorMultiply(colorHelper(colorScheme))
                }
            }.padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("AccentColor"))
                .edgesIgnoringSafeArea(.all)
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
            MenuView()
                .frame(width: geometry.size.width/2)
        }
    }
}
