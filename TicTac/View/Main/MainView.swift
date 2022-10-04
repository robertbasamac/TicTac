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
            List {
                ForEach(tm.timers) { timer in
                    TimerRowView(timer: timer)
                        .listRowInsets(.init(top: 4, leading: 20, bottom: 4, trailing: 4))
                }
            }
            .listStyle(.plain)
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        tm.createTimer(title: "Timer title", duration: 10)
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
            .environmentObject(TimerManager())
            .preferredColorScheme(.dark)
    }
}

