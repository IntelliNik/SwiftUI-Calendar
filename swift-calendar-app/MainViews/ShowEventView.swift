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
                        Text(event.startdate!, style: .date)
                        Spacer()
                        Image(systemName: "arrow.forward")
                        Spacer()
                        Text(event.enddate!, style: .date)
                    }.padding()
                    if(!event.wholeDay){
                        HStack{
                            Text(event.startdate!, style: .time)
                            Spacer()
                            Image(systemName: "clock.fill")
                            Spacer()
                            Text(event.enddate!, style: .time)
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
                            Text("\(event.repetitionInterval!)")
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
                        HStack{
                            Image(systemName: "location.fill").padding()
                            Spacer()
                            Text(event.locationName ?? "Location Name").padding()
                        }
                        let region = getRegionFromDatabase(latitude: event.latitude, longitude: event.longitude, latitudeDelta: event.latitudeDelta, longitudeDelta: event.longitudeDelta)
                        Map(coordinateRegion: .constant(region))
                            .frame(height: 200)
                    }
                }
                
                Section{
                    // TODO: doesn't really work within a List
                    if let url = event.url{
                        MetadataView(vm: LinkViewModel(link: url))
                        HStack{
                            Image(systemName: "globe").padding()
                            Spacer()
                            Text(url).padding()
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}){
                        Text("Edit")
                            .foregroundColor(Color(getAccentColorString()))
                    }
                }
            }
        }
    }
}

struct ShowEventView_Previews: PreviewProvider {
    static var previews: some View {
        ShowEventView(event: Event())
    }
}
