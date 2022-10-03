//
//  CircleButtonView.swift
//  TicTac
//
//  Created by Robert Basamac on 03.10.2022.
//

import SwiftUI

struct CircleButtonView: View {
    
    let iconName: String
    let foregroundColor: Color
    let backgroundColor: Color
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title2)
            .fontWeight(.medium)
            .foregroundColor(foregroundColor)
            .frame(width: 55, height: 55)
            .background(
                Circle()
                    .foregroundStyle(.tertiary)
                    .foregroundColor(backgroundColor)
            )
            .padding(8)
    }
}

struct CircleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonView(iconName: "play.fill", foregroundColor: .white, backgroundColor: .gray)
            .previewLayout(.sizeThatFits)
    }
}
