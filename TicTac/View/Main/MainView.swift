//
//  StopwatchView.swift
//  TicTac
//
//  Created by Robert Basamac on 27.09.2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var tm: TimerManager
    
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
            .listStyle(.plain)
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddtimer.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddtimer) {
                AddTimerView()
//                    .interactiveDismissDisabled()
                    .environmentObject(tm)
            }
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

