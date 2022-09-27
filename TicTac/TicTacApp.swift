//
//  TicTacApp.swift
//  TicTac
//
//  Created by Robert Basamac on 26.09.2022.
//

import SwiftUI

@main
struct TicTacApp: App {
    var body: some Scene {
        WindowGroup {
            StopwatchView()
                .preferredColorScheme(.dark)
        }
    }
}
