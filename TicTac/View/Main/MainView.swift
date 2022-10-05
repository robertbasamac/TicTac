//
//  StopwatchView.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import SwiftUI
import Combine

struct MainView: View {
    @EnvironmentObject private var tm: TimerManager
    
    @State var showAddtimer: Bool = false
    
//    @State var nextTimerDuration: Double = 0
    
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
                        showAddtimer.toggle()
//                        tm.createTimer(title: "Timer title", duration: 10)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddtimer) {
//                AddTimerView(returnedDuration: $nextTimerDuration)
                AddTimerView()
            }
//            .onChange(of: nextTimerDuration) { duration in
//                if duration > 0 {
//                    tm.createTimer(title: "Title", duration: duration)
//                    nextTimerDuration = 0
//                }
//            }
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

