//
//  MainView.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var tm: TimerManager
        
    @State private var timer: TimerModel? = nil
    @State private var editTimer: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                if !tm.activeTimers.isEmpty {
                    activeTimersSection
                }
                
                if !tm.otherTimers.isEmpty {
                    otherTimersSection
                }
            }
            .animation(.none, value: tm.activeTimers.isEmpty || tm.otherTimers.isEmpty)
            .listStyle(.plain)
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    sortButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .searchable(text: $tm.searchText, placement: .automatic, prompt: "Search")
        }
        .onAppear {
            NotificationManager.instance.requestAuthorization()
        }
        .sheet(item: $timer) { timer in
            AddTimerView(timer: timer, editTimer: $editTimer)
                .environmentObject(tm)
        }
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(dev.tm)
            .preferredColorScheme(.dark)
    }
}

extension MainView {
    
    private var activeTimersSection: some View {
        Section {
            ForEach(tm.activeTimers) { timer in
                TimerRowView(timer: timer)
                    .listRowInsets(.init(top: 4, leading: 20, bottom: 4, trailing: 20))
                    .onTapGesture {
                        self.editTimer = true
                        self.timer = timer
                    }
            }
            .onDelete { indexSet in
                tm.deleteTimer(indexSet: indexSet, active: true)
            }
        } header: {
            Text("Active timers")
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }
    
    private var otherTimersSection: some View {
        Section {
            ForEach(tm.otherTimers) { timer in
                TimerRowView(timer: timer)
                    .listRowInsets(.init(top: 4, leading: 20, bottom: 4, trailing: 20))
                    .onTapGesture {
                        self.editTimer = true
                        self.timer = timer
                    }
            }
            .onDelete { indexSet in
                tm.deleteTimer(indexSet: indexSet, active: false)
            }
        } header: {
            if !tm.activeTimers.isEmpty {
                Text("Other timers")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
    }
    
    private var sortButton: some View {
        Button {
            
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }
    
    private var addButton: some View {
        Button {
            self.editTimer = false
            self.timer = TimerModel()
        } label: {
            Image(systemName: "plus")
        }
    }
}
