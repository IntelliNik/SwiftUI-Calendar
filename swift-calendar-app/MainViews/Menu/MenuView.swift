//
//  MenuView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 22.12.21.
//

import SwiftUI

struct MenuView: View {
    let accentColorModes = ["AccentColorRed", "AccentColorGreen", "AccentColorBlue"]
    //@State var accentColor = getAccentColorString()
    //@EnvironmentObject var curColorScheme: CurrentColorScheme
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    @Binding var currentlySelectedView: ContainedView
    @Binding var showAddCalendar: Bool
    @Binding var menuOpen: Bool
    @Binding var title: String
    //@Binding var pickerState: String
    
    @State var calendarEditMode = false
    
    @FetchRequest(
        entity: MCalendar.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \MCalendar.name, ascending: true),
        ],
        predicate: NSPredicate(format: "defaultCalendar == %@", "NO")
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
                Button(action: {currentlySelectedView = .day; title = "Day View"; withAnimation{menuOpen = false}}) {
                    Text("Day View")
                        .padding()
                        .background(currentlySelectedView == .day ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .week; title = "Week View";  withAnimation{menuOpen = false}}) {
                    Text("Week View")
                        .padding()
                        .background(currentlySelectedView == .week ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .month; title = "Month View";  withAnimation{menuOpen = false}}) {
                    Text("Month View")
                        .padding()
                        .background(currentlySelectedView == .month ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .year; title = "Year View"; withAnimation{menuOpen = false}}) {
                    Text("Year View")
                        .padding()
                        .background(currentlySelectedView == .year ? Color(UIColor.darkGray) : .clear)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                Button(action: {currentlySelectedView = .allEvents; title = "All Events";  withAnimation{menuOpen = false}}) {
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
                        Text("Edit")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    Spacer()
                    Button(action: {showAddCalendar.toggle()}){
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }.padding(.bottom)
            }
            ScrollView(){
                VStack(alignment: .leading) {
                    HStack{
                            Image(systemName: "square.fill")
                                .foregroundColor(.yellow)
                                .imageScale(.large)
                            Text("Default")
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity)
                                .padding([.leading, .trailing])
                    }
                    .padding([.top, .bottom])
                    ForEach((0..<calendars.count),id: \.self) { index in
                        HStack{
                                Image(systemName: "square.fill")
                                    .foregroundColor(getColorFromString(stringColor: calendars[index].color ?? "Yellow"))
                                    .imageScale(.large)
                                Text("\(calendars[index].name!)")
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity)
                                    .padding([.leading, .trailing])
                        }
                        .padding([.top, .bottom])
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
                Picker(selection: $colorScheme, label: Text("Color Scheme")) {
                    Image(systemName: "flame").tag("red")
                    Image(systemName: "leaf").tag("green")
                    Image(systemName: "drop").tag("blue")
                    
                }
                .pickerStyle(.segmented)
                .foregroundColor(.white)
                .onChange(of: colorScheme){color in
                    //curColorScheme.set(colorScheme: color)
                    colorScheme = color
                }
                .padding()
            }
        }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .edgesIgnoringSafeArea(.all)
            .background(Color(getAccentColorString()))
        
            
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            MenuView(currentlySelectedView: .constant(.allEvents), showAddCalendar: .constant(false), menuOpen: .constant(true), title: .constant("Title"))
                .frame(width: geometry.size.width/2)
        }
        .environmentObject(CurrentColorScheme(.red))
    }
}
