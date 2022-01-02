//
//  ConfirmationBoxView.swift
//  swift-calendar-app
//
//  Created by Schulte, Niklas on 30.12.21.
//

import SwiftUI

struct ConfirmationBoxView: View {
    @State var success: Bool
    @State var text: String
    
    var body: some View {
        if(success){
            VStack{
                Image(systemName: "checkmark")
                    .resizable()
                    .padding(30)
                    .frame(width: 150, height: 150, alignment: .center)
                Text(text).padding()
            }
                .background(.gray)
                .cornerRadius(15)
        }else{
            VStack{
                Image(systemName: "xmark")
                    .resizable()
                    .padding(30)
                    .frame(width: 150, height: 150, alignment: .center)
                Text(text).padding()
            }
                .background(.gray)
                .cornerRadius(15)
        }
    }
}

struct ConfirmationBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationBoxView(success: true, text: "Event saved")
        ConfirmationBoxView(success: false, text: "Event discarded")
    }
}
