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
    @Environment(\.editMode) private var editMode
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var category: CategoryModel? = nil
    
    @State private var selections: [Int] = [0, 0, 0]
    
    private let data: [[String]] = [
        Array(0...23).map { "\($0)" },
        Array(0...59).map { "\($0)" },
        Array(0...59).map { "\($0)" }
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                PickerView(data: data, selections: $selections)

                Form {
                    HStack {
                        Text("Title")
                        
                        TextField("Timer", text: $title)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Alarm message")
                        
                        TextField("Message", text: $message)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    NavigationLink {
                        SelectCategoryView(category: $category)
                    } label: {
                        Text("Category")
                            .badge(category == nil ? "None" : category!.title)
                    }
                }
            }
            .navigationTitle("Add Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        tm.createTimer(timer: TimerModel(title: title == "" ? "Timer" : title, message: message, duration: getPickerDurationAsSeconds(), category: category))
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                    .disabled(getPickerDurationAsSeconds() == 0)
                }
            }
        }
        .onAppear {
            tm.isActive = false
            editMode?.wrappedValue = .inactive
        }
        .onWillDisappear {
            tm.isActive = true
        }
    }
}

struct AddTimerView_Previews: PreviewProvider {
    static var previews: some View {
        AddTimerView()
            .environmentObject(dev.tm)
    }
}

extension AddTimerView {
    
    private func getPickerDurationAsSeconds() -> Double {
        var duration: Double = 0
        
        duration += Double(selections[0] * 3600)
        duration += Double(selections[1] * 60)
        duration += Double(selections[2])
        
        return duration
    }
}
