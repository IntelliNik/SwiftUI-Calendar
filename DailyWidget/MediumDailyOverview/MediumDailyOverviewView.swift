//
//  MediumDailyOverviewView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 13.01.22.
//

import SwiftUI

struct MediumDailyOverviewView: View {
    @State var dateComponents = Calendar.current.dateComponents([.day, .month], from: Date.now)
    
    var body: some View {
        GeometryReader{geometry in
            HStack(spacing: 0){
                SmallDailyOverviewView(dateComponents: dateComponents)
                    .frame(width: geometry.size.width * 0.4)
                Text("-")
                //MonthView(dateComponents: $dateComponents)
                 //   .frame(width: geometry.size.width * 0.6)
            }
        }
    }
}

struct MediumDailyOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        MediumDailyOverviewView()
    }
}
