//
//  ConfirmationBoxView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 30.12.21.
//

import SwiftUI

enum ConfirmationBoxModes{
    case success
    case fail
    case loading
}

struct ConfirmationBoxView: View {
    @State var mode: ConfirmationBoxModes
    @State var text: String
    
    @State var isAnimating = false
    var animation = Animation.easeInOut(duration: 2).repeatForever(autoreverses: false)
    
    var body: some View {
        VStack{
            switch mode{
            case .success:
                VStack{
                    Image(systemName: "checkmark")
                        .resizable()
                        .padding(30)
                        .frame(width: 150, height: 150, alignment: .center)
                }
            case .fail:
                VStack{
                    Image(systemName: "xmark")
                        .resizable()
                        .padding(30)
                        .frame(width: 150, height: 150, alignment: .center)
                }
            case .loading:
                VStack{
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 60))
                        .padding(30)
                        .frame(width: 150, height: 150, alignment: .center)
                        .rotationEffect(Angle(degrees: isAnimating ? 540 : 0))
                        .animation(animation, value: isAnimating)
                        .onAppear {
                            isAnimating = true
                        }
                }
            }
            Text(text).padding()
        }
        .background(.gray)
        .cornerRadius(15)
    }
}

struct ConfirmationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationBoxView(mode: .success, text: "Event saved")
        ConfirmationBoxView(mode: .fail, text: "Event discarded")
    }
}
