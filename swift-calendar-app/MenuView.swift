//
//  MenuView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 22.12.21.
//

import SwiftUI

struct MenuView: View {
    let accentColorModes = ["AccentColorRed", "AccentColorGreen", "AccentColorBlue"]
    @State var accentColor = getAccentColor()
    
    @Binding var currentlySelectedView: ContainedView
    @Binding var showAddCalendar: Bool
    
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
                        .background(currentlySelectedView == .day ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .week}) {
                    Text("Week View")
                        .padding()
                        .background(currentlySelectedView == .week ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .month}) {
                    Text("Month View")
                        .padding()
                        .background(currentlySelectedView == .month ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .year}) {
                    Text("Year View")
                        .padding()
                        .background(currentlySelectedView == .year ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .allEvents}) {
                    Text("All Events")
                        .padding()
                        .background(currentlySelectedView == .allEvents ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Rectangle()
                    .fill(.white)
                    .frame(height: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                    .padding([.top, .bottom])
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {showAddCalendar.toggle()}){
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                    .padding(.bottom, 5)
                }
            }
            ScrollView{
                VStack(alignment: .leading) {
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
                    .background(currentlySelectedCalendar == 0 ? Color(UIColor.darkGray) : .clear)
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
                    .background(currentlySelectedCalendar == 1 ? Color(UIColor.darkGray) : .clear)
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
                    .background(currentlySelectedCalendar == 2 ? Color(UIColor.darkGray) : .clear)
                    HStack{
                        Button(action: {currentlySelectedCalendar = 3}) {
                            Image(systemName: "square.fill")
                                .foregroundColor(.orange)
                                .imageScale(.large)
                            Text("Calendar 4")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(currentlySelectedCalendar == 3 ? Color(UIColor.darkGray) : .clear)
                    HStack{
                        Button(action: {currentlySelectedCalendar = 4}) {
                            Image(systemName: "square.fill")
                                .foregroundColor(.purple)
                                .imageScale(.large)
                            Text("Calendar 5")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(currentlySelectedCalendar == 4 ? Color(UIColor.darkGray) : .clear)
                }
            }
            Rectangle()
                .fill(.white)
                .frame(height: 2)
                .edgesIgnoringSafeArea(.horizontal)
                .padding([.top, .bottom])
            VStack(alignment: .leading){
                Text("Color scheme")
                    .font(.headline)
                    .foregroundColor(.white)
                Picker(selection: $accentColor, label: Text("Color Scheme")) {                        Image(systemName: "flame").tag("AccentColorRed")
                    Image(systemName: "leaf").tag("AccentColorGreen")
                    Image(systemName: "drop").tag("AccentColorBlue")
                    
                }
                .pickerStyle(.segmented)
                .foregroundColor(.white)
                .onChange(of: accentColor){color in
                    setAccentColor(colorScheme: color)
                }
                .padding()
            }
        }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(accentColor))
            .edgesIgnoringSafeArea(.all)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            MenuView(currentlySelectedView: .constant(.allEvents), showAddCalendar: .constant(false))
                .frame(width: geometry.size.width/2)
        }
    }
}
