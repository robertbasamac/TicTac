//
//  PreviewProvider.swift
//  TicTac
//
//  Created by Robert Basamac on 02.10.2022.
//

import Foundation
import SwiftUI

extension PreviewProvider {
    
    static var dev: DeveloperPreview {
        return DeveloperPreview.shared
    }
}

class DeveloperPreview {
    
    static let shared = DeveloperPreview()
    
    private init() { }
    
    let tm: TimerManager = TimerManager()
    
    let category = CategoryModel(title: "Bucatarie", color: .orange)
    
    let timer = TimerModel(title: "Timer title", message: "This is a message", duration: 36648, category: CategoryModel(title: "Bucatarie", color: .orange))
}
