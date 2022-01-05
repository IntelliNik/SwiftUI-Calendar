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
                    .navigationTitle("Event: \(event.name ?? "")")
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
                            if(event.wholeDay){
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
                    }.padding()
                }
                Section{
                    HStack{
                        Image(systemName: "repeat")
                        Spacer()
                        if(event.repetition){
                            HStack{
                                Text("\(event.repetitionInterval!), \(event.repetitionUntil!)")
                                if(event.repetitionUntil! == "Repetitions"){
                                    Text(", \(event.repetitionAmount)")
                                }
                                if(event.repetitionUntil! == "End Date"){
                                    HStack{
                                        Text(", until")
                                        Text(event.repetitionEndDate!, style: .date)
                                    }
                                }
                            }
                        } else {
                            Text("None")
                        }
                    }.padding()
                }
            }
        }
    }
}
                
            /*


                Section{
                    HStack{
                        Text("Location")
                            .padding()
                        Picker("Location", selection: $location) {
                            ForEach(locationModes, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                    }
                    if(location == "Current"){
                        Map(coordinateRegion: $currentRegion, showsUserLocation: true, userTrackingMode: .constant(.follow))
                            .frame(minHeight: 200)
                    }
                    if(location == "Custom"){
                        HStack{
                            TextField("Search for location ...", text: $locationSearch)
                                .autocapitalization(.none)
                                .padding()
                            Image(systemName: "magnifyingglass")
                        }
                        Map(coordinateRegion: $customRegion)
                            .frame(minHeight: 200)
                    }
                }
                Section{
                    TextField("URL", text: $urlString)
                        .padding()
                        .autocapitalization(.none)
                        .onChange(of: urlString){ url in
                            //metadataView = MetadataView(vm: LinkViewModel(link: url))
                        }
                    TextField("Notes", text: $notes)
                        .autocapitalization(.none)
                        .padding()

    
    func generateID (startDate: Date, endDate: Date, name: String) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        let randomInt = Int.random(in: 1..<100000)
        
        return name + formatter.string(from: startDate) + formatter.string(from: endDate) + String(randomInt)
    }
    
    func calendarAddEvent(name: String, event: Event ){
        if calendars.isEmpty{
            //TODO: Tell the user that no calendar exists
        } else {
            for calendar in calendars{
                if (calendar.name == name){
                    calendar.addToEvents(event)
                    break
                }

            }
        }
    }
}
             

NavigationView(){
    VStack{
    Text("URL: \(url)")
    // TODO: this preview can be used to visualize the link of an event
    MetadataView(vm: LinkViewModel(link: url))
        .padding()
        .frame(maxHeight: 400)
        .navigationTitle("Event: \"Apple Event\"")
    }
}*/

/*
struct ShowEventView_Previews: PreviewProvider {
    static var previews: some View {
        ShowEventView(url: "https://apple.com")
    }
}
*/
