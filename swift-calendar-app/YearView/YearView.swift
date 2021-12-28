//
//  YearView.swift
//  swift-calendar-app
//
//  Created by Daniel Rademacher on 27.12.21.
//

import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SwitchYearButton: View {
    var year: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: nil) {
            
            ZStack(alignment: .center){
                Button() {
                } label: {
                    NavigationLink(destination: YearView(year:(year-1)))
                    {
                    Text("   " + String(year-1) + "   " )
                        .font(.system(size: 17, weight: .bold, design: .default))
                    }
                }
                .buttonStyle(GrowingButton())
                    .offset(x:-10 , y: 0)
                
                //Text("    " + String(year-1) + "    ")
                //    .fontWeight(.bold)
                //    .padding()
                //    .background(Color.red)
                //    .cornerRadius(40)
                //    .foregroundColor(.white)
                //    .overlay(
                //        RoundedRectangle(cornerRadius: 40)
                //            .stroke(Color.red, lineWidth: 2)
                //    )
                //    .offset(x:-20 , y: 0)
                
            }
            
            ZStack(alignment: .center){
                Button() {
                    
                } label: {
                    Text("   " + String(year) + "   " )
                        .font(.system(size: 17, weight: .bold, design: .default))
                }
                .buttonStyle(GrowingButton())
                
                //Text("    " + String(year) + "    ")
                //    .fontWeight(.bold)
                //    .padding()
                //    .background(Color.red)
                //    .cornerRadius(40)
                //    .foregroundColor(.white)
                //    .overlay(
                //        RoundedRectangle(cornerRadius: 40)
                //            .stroke(Color.red, lineWidth: 2)
                //    )
                //    .offset(x:0 , y: 0)
            }
            
            ZStack(alignment: .center)
            {
                Button() {
                } label: {
                    NavigationLink(destination:
                        YearView(year:(year+1))
                    ){
                    Text("   " + String(year+1) + "   " )
                        .font(.system(size: 17, weight: .bold, design: .default))
                    }
                }
                .buttonStyle(GrowingButton())
                    .offset(x:10 , y: 0)
                
                //Text("    " + String(year+1) + "    ")
                //    .fontWeight(.bold)
                //    .padding()
                //    .background(Color.red)
                //    .cornerRadius(40)
                //    .foregroundColor(.white)
                //    .overlay(
                //        RoundedRectangle(cornerRadius: 40)
                //            .stroke(Color.red, lineWidth: 2)
                //    )
                //    .offset(x:20 , y: 0)
            }
        }
    }
}

struct YearView: View {
    //struct Year {
    //    var month : Int
    //    var year : Int
    //}
    var year : Int
    
    var body: some View {
        
            VStack {
                YearViewYearAndToday(year: year)
                Spacer()
                YearViewCalendar(year: year)
                Spacer()
                Spacer()
                Spacer()
                
                SwitchYearButton(year: year)
            }.padding() 
        
        
    }
}

struct YearView_Previews: PreviewProvider {
    static var previews: some View {
        YearView(year: 2021)
    }
}
