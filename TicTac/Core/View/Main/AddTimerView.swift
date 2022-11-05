//
//  AddTimerView.swift
//  TicTac
//
//  Created by Robert Basamac on 04.10.2022.
//

import SwiftUI

struct AddTimerView: View {
    
    @EnvironmentObject private var tm: TimerManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State var timer: TimerModel
    @Binding var editTimer: Bool
    
    @State private var selections: [Int] = Array(repeating: 0, count: 3)
    
    private let data: [[String]] = [
        Array(0...23).map { "\($0)" },
        Array(0...59).map { "\($0)" },
        Array(0...59).map { "\($0)" }
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    PickerViewRepresentable(data: data, selections: $selections)
                        .frame(maxWidth: .infinity)
                    
                    Text(selections[0] > 1 ? "hours" : "hour")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(width: 50, alignment: .leading)
                        .offset(x: -62)
                    
                    Text("min")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(width: 35, alignment: .leading)
                        .offset(x: 34)
                    
                    Text("sec")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(width: 30, alignment: .leading)
                        .offset(x: 132)
                }

                timerInfoSection
            }
            .navigationTitle(editTimer ? "Edit Timer" : "Add Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    dismissButton
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    saveButton
                        .disabled(getPickerDurationInSeconds() == 0)
                }
            }
        }
        .onAppear {
            tm.allowUpdateTimers = false
            selections = getTimerDurationAsArrayHMS(ofTimer: self.timer)
        }
        .onWillDisappear {
            tm.allowUpdateTimers = true
        }
    }
}

struct AddTimerView_Previews: PreviewProvider {
    static var previews: some View {
        AddTimerView(timer: dev.timer, editTimer: .constant(false))
            .environmentObject(dev.tm)
    }
}

extension AddTimerView {
    
    private var timerInfoSection: some View {
        Form {
            HStack {
                Text("Title")
                
                TextField("Timer", text: $timer.title)
                    .multilineTextAlignment(.trailing)
            }

            HStack {
                Text("Alarm message")
                
                TextField("Message", text: $timer.alarmMessage)
                    .multilineTextAlignment(.trailing)
            }
            
            NavigationLink {
                SelectCategoryView(category: $timer.category)
            } label: {
                Text("Category")
                    .badge(timer.category == nil ? "None" : timer.category!.title)
            }
            
            if editTimer {
                Section {
                    Button(role: .destructive) {
                        tm.deleteTimer(timer)
                        dismiss()
                    } label: {
                        Text("Delete Timer")
                            .frame(maxWidth: .infinity)
                    }

                }
            }
        }
    }
    
    private var saveButton: some View {
        Button {
            timer.duration = getPickerDurationInSeconds()
            tm.updateTimer(timer)
            
            dismiss()
        } label: {
            Text("Save")
        }
    }
    
    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
        }
    }
    
    private func getPickerDurationInSeconds() -> Double {
        var duration: Double = 0
        
        duration += Double(selections[0] * 3600)
        duration += Double(selections[1] * 60)
        duration += Double(selections[2])
        
        return duration
    }
    
    private func getTimerDurationAsArrayHMS(ofTimer timer: TimerModel) -> [Int] {
        var time: [Int] = Array(repeating: 0, count: 3)
        
        let duration: Int = Int(timer.duration)
        
        time[0] = duration / 3600
        time[1] = (duration % 3600) / 60
        time[2] = (duration % 3600) % 60
        
        return time
    }
}
