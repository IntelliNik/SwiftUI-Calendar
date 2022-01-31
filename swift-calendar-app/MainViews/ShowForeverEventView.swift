//
//  SwiftUIView.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 19.01.22.
//

import SwiftUI
import MapKit

// View to display an ForeverEvent
// View is called if an foreverEvent is clicked in the DayView or WeekView

struct ShowForeverEventView: View {
    
    // Which foreverEvent should be displayed
    @State var event: ForeverEvent
    @State var showShowEvent = false
    @State var showConfirmation = false
    @State var saveEvent = false
    @State var confirmationShown = false
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        NavigationView{
            Form{
                // Section to display the calendar of event
                Section{
                    HStack{
                        if let calendar = event.calendar{
                            Image(systemName: "square.fill")
                                .foregroundColor(getColorFromString(stringColor: calendar.color))
                                .imageScale(.large)
                        }
                        Text("\(event.calendar?.name ?? "No Calendar")")
                    }
                }.padding()
                
                // Section to display startDate, endDate and wholeDay
                // We have to check whether the values are nil, i.e. the event has been deleted
                Section{
                    HStack{
                        Text(event.startdate ?? Date.now, style: .date)
                        Spacer()
                        Image(systemName: "arrow.forward")
                        Spacer()
                        Text(event.enddate ?? Date.now, style: .date)
                    }.padding()
                    if(event.wholeDay){
                        HStack{
                            Text(event.startdate ?? Date.now, style: .time)
                            Spacer()
                            Image(systemName: "clock.fill")
                            Spacer()
                            Text(event.enddate ?? Date.now, style: .time)
                        }.padding()
                    }
                }
                
                // Section to display notification and repetition
                Section{
                    HStack{
                        Image(systemName: "bell.fill")
                        Spacer()
                        if(event.notification){
                            if(!event.wholeDay){
                                Text("\(event.notificationMinutesBefore) minutes before")
                            } else{
                                HStack{
                                    Text("At")
                                    Text(event.notificationTimeAtWholeDay!, style: .time)
                                }
                            }
                        } else{
                            Text("None")
                        }
                    }
                    // Note that foreverEvents always have a repetitionInterval
                    HStack{
                        Image(systemName: "repeat")
                        Spacer()
                        Text("\(event.repetitionInterval ?? "Daily")")
                    }
                }.padding()
                
                // Section to display location
                Section{
                    // Use MapKit to display the location
                    if(event.location){
                        let region = getRegionFromDatabase(latitude: event.latitude, longitude: event.longitude, latitudeDelta: event.latitudeDelta, longitudeDelta: event.longitudeDelta)
                        Map(coordinateRegion: .constant(region))
                            .frame(height: 200)
                    }
                }
                
                // Section to display url and notes
                Section{
                    if let urlString = event.url{
                        HStack{
                            Image(systemName: "globe").padding()
                            Spacer()
                            if let url = URL(string: urlString) {
                                Link(getURLwithoutProtocol(urlString: urlString), destination: url)
                                    .foregroundColor(.blue)
                            } else{
                                Text(urlString)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    if let notes = event.notes{
                        HStack{
                            Image(systemName: "note.text").padding()
                            Spacer()
                            Text(notes).padding()
                        }
                    }
                }
            }
            .navigationTitle(event.name != nil ? "Event: \(event.name!)" : "Show Event")
            .toolbar{
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {dismiss()}){
                        HStack{
                            Image(systemName: "chevron.left")
                                .font(Font.headline.weight(.bold))
                                .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                            Text("Back")
                                .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Button to edit event
                    // The button calls EditForeverEventView as a view
                    Button(action: {confirmationShown = true}){
                        Text("Edit")
                            .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                    }
                    .sheet(isPresented: $confirmationShown) {
                        EditForeverEventView(event: event, locationService: LocationService(), saveEvent: .constant(true), showConfirmation: .constant(true))
                            .onDisappear(perform: {
                            confirmationShown = false
                        })
                    }
                }
            }
        }
        .onChange(of: confirmationShown, perform: {_ in
            // If the event is deleted, the view is dismissed
            if event.key == nil {
                dismiss()
            }
        })
    }
}
