//
//  CurHourMarker.swift
//  swift-calendar-app
//
//  Created by Farhadiba Mohammed on 15.01.22.
//

import SwiftUI

struct CurHourMarker: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10.0)
                    .stroke(lineWidth: 2.0)
    }
}

struct CurHourMarker_Previews: PreviewProvider {
    static var previews: some View {
        CurHourMarker()
    }
}
