//
//  ShowEventView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 01.01.22.
//

import SwiftUI
import MapKit

struct ShowEventView: View {
    
    @State var event: Event
    
    @State var showShowEvent = false
    
    @State var showConfirmation = false
    
    @State var saveEvent = false
    
    @State var confirmationShown = false
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("colorScheme") private var colorScheme = "red"
    
    var body: some View {
        NavigationView{
            Form{
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
                Section{
                    HStack{
                        Text(event.startdate ?? Date.now, style: .date)
                        Spacer()
                        Image(systemName: "arrow.forward")
                        Spacer()
                        Text(event.enddate ?? Date.now, style: .date)
                    }.padding()
                    if(!event.wholeDay){
                        HStack{
                            Text(event.startdate ?? Date.now, style: .time)
                            Spacer()
                            Image(systemName: "clock.fill")
                            Spacer()
                            Text(event.enddate ?? Date.now, style: .time)
                        }.padding()
                    }
                }
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
                    HStack{
                        Image(systemName: "repeat")
                        Spacer()
                        if(event.repetition){
                            Text("\(event.repetitionInterval ?? "Daily")")
                        }else {
                            Text("None")
                        }
                    }
                    if(event.repetition){
                        if(event.repetitionUntil! == "Repetitions"){
                            HStack{
                                Text("Repetitions: ")
                                Spacer()
                                Text("\(event.repetitionAmount)")
                            }
                        }
                        if(event.repetitionUntil! == "End Date"){
                            HStack{
                                Text("End Date: ")
                                Spacer()
                                Text(event.repetitionEndDate!, style: .date)
                            }
                        }
                    }
                }.padding()
                Section{
                    if(event.location){
                        let region = getRegionFromDatabase(latitude: event.latitude, longitude: event.longitude, latitudeDelta: event.latitudeDelta, longitudeDelta: event.longitudeDelta)
                        Map(coordinateRegion: .constant(region))
                            .frame(height: 200)
                    }
                }
                
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
                    Button(action: {confirmationShown = true}){
                        Text("Edit")
                            .foregroundColor(Color(getAccentColorString(from: colorScheme)))
                    }
                    .sheet(isPresented: $confirmationShown) {
                        EditEventView(event: event, locationService: LocationService(), saveEvent: .constant(true), showConfirmation: .constant(true))
                            .onDisappear(perform: {
                            confirmationShown = false
                        })
                    }
                }
            }
        }
        .onChange(of: confirmationShown, perform: {_ in
            if event.key == nil {
                dismiss()
            }
        })
    }
}
