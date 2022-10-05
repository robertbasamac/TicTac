//
//  CircleButtonView.swift
//  TicTac
//
//  Created by Robert Basamac on 03.10.2022.
//

import SwiftUI

struct CircleButtonView: View {
    
    private let iconName: String
    private let foregroundColor: Color
    private let backgroundColor: Color
    
    init(iconName: String, foregroundColor: Color, backgroundColor: Color) {
        self.iconName = iconName
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 18, weight: .medium, design: .default))
            .foregroundColor(foregroundColor)
            .frame(width: 45, height: 45)
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
        CircleButtonView(iconName: "play.fill", foregroundColor: .green, backgroundColor: .green)
            .previewLayout(.sizeThatFits)
    }
}
