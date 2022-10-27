//
//  MainView.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var tm: TimerManager
    
    @State private var editMode = EditMode.inactive
    
    @State private var timer: TimerModel? = nil
    @State private var editTimer: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tm.timers) { timer in
                    TimerRowView(timer: timer)
                        .listRowInsets(.init(top: 4, leading: 20, bottom: 4, trailing: 20))
                        .onTapGesture {
                            self.editTimer = true
                            self.timer = timer
                        }
                }
                .onDelete(perform: tm.deleteTimer)
                .onMove(perform: tm.moveTimer)
            }
            .listStyle(.plain)
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    editButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .environment(\.editMode, $editMode)
            .searchable(text: $tm.searchText, placement: .automatic, prompt: "Search")
        }
        .onAppear {
            NotificationManager.instance.requestAuthorization()
        }
        .onChange(of: tm.timers.count) { newValue in
            if editMode == .active && newValue == 0 {
                editMode = .inactive
            }
        }
        .sheet(item: $timer) { timer in
            AddTimerView(timer: timer, editTimer: $editTimer)
                .environmentObject(tm)
                .environment(\.editMode, $editMode)
        }
    }
    
    private var editButton: some View {
        return Group {
            switch editMode {
            case .inactive:
                if tm.timers.count == 0 {
                    EmptyView()
                } else {
                    EditButton()
                }
            case .active:
                EditButton()
            default:
                EmptyView()
            }
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

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(dev.tm)
            .preferredColorScheme(.dark)
    }
}
