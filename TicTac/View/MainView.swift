//
//  StopwatchView.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var tm: TimerManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach($tm.timers) { timer in
                        TimerView(timer: timer)
                    }
                }
            }
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        tm.createTimer(title: "Test", duration: 10)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

