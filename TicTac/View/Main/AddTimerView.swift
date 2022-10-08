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
    
    @State private var secondsSelection: Int = 0
    @State private var minutesSelection: Int = 0
    @State private var hoursSelection: Int = 0
    
    @State private var label: String = ""
    
    private var seconds: [Int] = [Int](0..<60)
    private var minutes: [Int] = [Int](0..<60)
    private var hours: [Int] = [Int](0..<24)
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 20) {
//                    hoursPicker
//                    minutesPicker
                    secondsPicker
                }
                .padding(.horizontal, 20)
//                .animation(.default, value: UUID())
//                .frame(width: 300, height: 300)

                List {
                    TextField("Label", text: $label)
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
                        tm.createTimer(title: label == "" ? "Timer" : label, duration: getPickerDurationAsSeconds())
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
            .environmentObject(TimerManager())
    }
}

extension AddTimerView {
    
    private var hoursPicker: some View {
        ZStack {
            Picker(selection: $hoursSelection) {
                ForEach(hours, id: \.self) { index in
                    Text("\(index)").tag(index)
                        .font(.title3)
                        .frame(width: 30, alignment: .trailing)
                        .offset(x: -28)
                }
            } label: {
                Text("Hours")
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            
            Text(hoursSelection == 1 ? "hour" : "hours")
                .font(.headline)
                .frame(width: 70, alignment: .leading)
                .offset(x: 24)
        }
    }
    
    private var minutesPicker: some View {
        ZStack {
            Picker(selection: $minutesSelection) {
                ForEach(minutes, id: \.self) { index in
                    Text("\(index)").tag(index)
                        .font(.title3)
                        .frame(width: 30, alignment: .trailing)
                        .offset(x: -22)
                }
            } label: {
                Text("Minutes")
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            
            Text("min")
                .font(.headline)
                .frame(width: 50, alignment: .leading)
                .offset(x: 20)
        }
    }
    
    private var secondsPicker: some View {
        ZStack(alignment: .center) {
            Picker(selection: $secondsSelection) {
                ForEach(seconds, id: \.self) { index in
                    Text("\(index)").tag(index)
                        .font(.title3)
                        .frame(width: 30, alignment: .trailing)
                        .offset(x: -22)
                }
            } label: {
                Text("Seconds")
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            
            Text("sec")
                .font(.headline)
                .frame(width: 50, alignment: .leading)
                .offset(x: 20)
        }
    }
    
    private func getPickerDurationAsSeconds() -> Double {
        var duration: Double = 0
        
        duration += Double(hoursSelection) * 60 * 60
        duration += Double(minutesSelection) * 60
        duration += Double(secondsSelection)
        
        return duration
    }
}

//extension UIPickerView {
//    
//    open override var intrinsicContentSize: CGSize {
//        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
//    }
//}
