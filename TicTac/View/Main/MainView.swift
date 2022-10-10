//
//  StopwatchView.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var tm: TimerManager
    
    @State private var editMode = EditMode.inactive
    @State private var showAddtimer: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tm.timers) { timer in
                    TimerRowView(timer: timer)
                        .listRowInsets(.init(top: 4, leading: 20, bottom: 4, trailing: 20))
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    editButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .listStyle(.plain)
            .navigationTitle("Timers")
            .environment(\.editMode, $editMode)
            .onChange(of: tm.timers.count) { newValue in
                if editMode == .active && tm.timers.count == 0 {
                    editMode = .inactive
                }
            }
            .sheet(isPresented: $showAddtimer) {
                AddTimerView()
                    .environmentObject(tm)
                    .environment(\.editMode, $editMode)
            }
        }
        .onAppear {
            NotificationManager.instance.requestAuthorization()
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
            showAddtimer.toggle()
        } label: {
            Image(systemName: "plus")
        }
    }
    
    private func delete(indexSet: IndexSet) {
        tm.deleteTimer(indexSet: indexSet)
    }
    
    private func move(indices: IndexSet, newOffset: Int) {
        tm.moveTimer(fromOffsets: indices, toOffset: newOffset)
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(TimerManager())
            .preferredColorScheme(.dark)
    }
}
