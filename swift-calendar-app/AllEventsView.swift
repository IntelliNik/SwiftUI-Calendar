//
//  SwiftUIView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 19.12.21.
//

import SwiftUI


struct AllEventsView: View {
    @StateObject var dataSource = DayDataModel()
    
    @State private var scrollTargetTodayButton: UUID?
    @State private var showMenu = false
    @State private var showAddEventSheet = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let drag = DragGesture()
            .onEnded { value in
                withAnimation {
                    self.showMenu = false
                }
            }
        GeometryReader { geometry in
            NavigationView{
                ZStack(alignment: .leading){
                    ScrollViewReader { reader in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading){
                                Spacer()
                                ForEach(dataSource.items) { item in
                                    Text(item.date!, style: .date)
                                        .padding(.top, 30)
                                        .padding(.leading, 10)
                                        .onAppear {
                                            dataSource.loadMoreContentIfNeeded(currentDate: item)
                                        }
                                }
                            }.navigationTitle("All Events")
                                .toolbar {
                                    ToolbarItem(placement: .navigation) {
                                        Button(action: {self.showMenu.toggle()}) {
                                            Image(systemName: "line.horizontal.3")
                                        }
                                    }
                                    ToolbarItem(placement: .primaryAction) {
                                        Button(action: {showAddEventSheet.toggle()}) {
                                            Image(systemName: "plus")
                                        }
                                        .sheet(isPresented: $showAddEventSheet) {
                                            AddEventView()
                                                .interactiveDismissDisabled(true)
                                        }
                                    }
                                }
                            
                        }
                        .onAppear(){
                            // TODO: not working....
                            reader.scrollTo(dataSource.getIdentifyableToday()?.id)
                        }
                        .onChange(of: scrollTargetTodayButton) { target in
                            if let target = target {
                                // reset scroll target
                                scrollTargetTodayButton = nil
                                withAnimation {
                                    reader.scrollTo(target, anchor: .top)
                                }
                            }
                        }
                    }
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Button(action: {
                                if let today = dataSource.getIdentifyableToday(){
                                    scrollTargetTodayButton = today.id
                                }
                            }, label: {
                                Text("Today")
                                    .font(.system(.title))
                                    .foregroundColor(.white)
                                    .padding(10)
                            })
                                .background(Color("AccentColor"))
                                .cornerRadius(45)
                                .shadow(color: Color.black.opacity(0.3),
                                        radius: 3,
                                        x: 3,
                                        y: 3)
                                .padding(20)
                        }
                    }.ignoresSafeArea()
                }
            }
            if self.showMenu {
                MenuView()
                    .frame(width: geometry.size.width/2)
            }
        }.gesture(drag)
        // TODO: add a gesture for tapping to the right of the menu to also close it
    }
    
    
    struct EndlessListView_Previews: PreviewProvider {
        static var previews: some View {
            AllEventsView()
        }
    }
}
