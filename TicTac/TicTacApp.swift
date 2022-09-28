//
//  TicTacApp.swift
//  TicTac
//
//  Created by Robert Basamac on 26.09.2022.
//

import SwiftUI

@main
struct TicTacApp: App {
    @StateObject var timerManager = TimerManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
                .environmentObject(timerManager)
        }
    }
}
