//
//  CircleButtonView.swift
//  TicTac
//
//  Created by Robert Basamac on 03.10.2022.
//

import SwiftUI

struct CircleButtonView: View {
        
    enum ButtonStyle {
        case start
        case pause
        case reset
        
        var iconName: String {
            switch self {
            case .start:
                return "play.fill"
            case .pause:
                return "pause.fill"
            case .reset:
                return "xmark"
            }
        }
                
        var foregroundColor: Color {
            switch self {
            case .start:
                return .green
            case .pause:
                return .orange
            case .reset:
                return .white
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .start:
                return .green
            case .pause:
                return .orange
            case .reset:
                return .gray
            }
        }
    }
    
    private var style: ButtonStyle
    
    init(style: ButtonStyle) {
        self.style = style
    }
    
    var body: some View {
        Image(systemName: style.iconName)
            .font(.system(size: 18, weight: .medium, design: .default))
            .foregroundColor(style.foregroundColor)
            .frame(width: 45, height: 45)
            .background(
                Circle()
                    .foregroundStyle(.tertiary)
                    .foregroundColor(style.backgroundColor)
            )
            .padding(4)
    }
}

struct CircleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonView(style: .start)
            .previewLayout(.sizeThatFits)
    }
}
