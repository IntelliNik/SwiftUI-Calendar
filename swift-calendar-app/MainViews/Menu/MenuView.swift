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
    @Binding var menuOpen: Bool
    
    @State var calendarEditMode = false
    @State var currentlySelectedCalendar: Int = 0
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ]
    ) var calendars: FetchedResults<MCalendar>
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
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
                Button(action: {currentlySelectedView = .day; withAnimation{menuOpen = false}}) {
                    Text("Day View")
                        .padding()
                        .background(currentlySelectedView == .day ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .week;  withAnimation{menuOpen = false}}) {
                    Text("Week View")
                        .padding()
                        .background(currentlySelectedView == .week ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .month;  withAnimation{menuOpen = false}}) {
                    Text("Month View")
                        .padding()
                        .background(currentlySelectedView == .month ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .year;  withAnimation{menuOpen = false}}) {
                    Text("Year View")
                        .padding()
                        .background(currentlySelectedView == .year ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .allEvents;  withAnimation{menuOpen = false}}) {
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
                    Button(action: {calendarEditMode.toggle()}){
                        Text("Manage")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {showAddCalendar.toggle()}){
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }.padding(.bottom)
            }
            ScrollView(){
                VStack(alignment: .leading) {
                    ForEach((0..<calendars.count),id: \.self) { index in
                        HStack{
                            Button(action: {currentlySelectedCalendar = index}) {
                                Image(systemName: "square.fill")
                                    .foregroundColor(getColorFromString(stringColor: calendars[index].color ?? "Yellow"))
                                    .imageScale(.large)
                                Text("\(String((calendars[index].name!).prefix(10)))")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(currentlySelectedCalendar == index ? Color(UIColor.darkGray) : .clear)
                    }
                }
            }
            .sheet(isPresented: $calendarEditMode){
                EditCalendarView()
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
            MenuView(currentlySelectedView: .constant(.allEvents), showAddCalendar: .constant(false), menuOpen: .constant(true))
                .frame(width: geometry.size.width/2)
        }
    }
}
