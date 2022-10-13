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
    
    @State private var hoursSelection: Int = 0
    @State private var minutesSelection: Int = 0
    @State private var secondsSelection: Int = 0
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var category: CategoryModel = CategoryModel(title: "", color: .white)
    
//    private var seconds: [Int] = [Int](0..<60)
//    private var minutes: [Int] = [Int](0..<60)
//    private var hours: [Int] = [Int](0..<24)
    
    private let data: [[String]] = [
        Array(0...23).map { "\($0)" },
        Array(0...59).map { "\($0)" },
        Array(0...59).map { "\($0)" }
    ]
    
    @State private var selections: [Int] = [0, 0, 0]
    
    var body: some View {
        NavigationStack {
            VStack {
//                HStack(spacing: 20) {
//                    hoursPicker
//                    minutesPicker
//                    secondsPicker
                    PickerView(data: data, selections: $selections)
//                }
//                .padding(.horizontal, 20)
//                .animation(.default, value: UUID())
//                .frame(width: 300, height: 300)

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
                            .badge(category.title.isEmpty ? "None" : category.title)
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
                        tm.createTimer(title: title.isEmpty ? "Timer" : title, message: message, duration: getPickerDurationAsSeconds(), category: category)
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
    
//    private var hoursPicker: some View {
//        ZStack {
//            Picker(selection: $hoursSelection) {
//                ForEach(hours, id: \.self) { index in
//                    Text("\(index)").tag(index)
//                        .font(.title3)
//                        .frame(width: 30, alignment: .trailing)
//                        .offset(x: -28)
//                }
//            } label: {
//                Text("Hours")
//            }
//            .pickerStyle(.wheel)
//            .labelsHidden()
//
//            Text(hoursSelection == 1 ? "hour" : "hours")
//                .font(.headline)
//                .frame(width: 70, alignment: .leading)
//                .offset(x: 24)
//        }
//    }
//
//    private var minutesPicker: some View {
//        ZStack {
//            Picker(selection: $minutesSelection) {
//                ForEach(minutes, id: \.self) { index in
//                    Text("\(index)").tag(index)
//                        .font(.title3)
//                        .frame(width: 30, alignment: .trailing)
//                        .offset(x: -22)
//                }
//            } label: {
//                Text("Minutes")
//            }
//            .pickerStyle(.wheel)
//            .labelsHidden()
//
//            Text("min")
//                .font(.headline)
//                .frame(width: 50, alignment: .leading)
//                .offset(x: 20)
//        }
//    }
//
//    private var secondsPicker: some View {
//        ZStack(alignment: .center) {
//            Picker(selection: $secondsSelection) {
//                ForEach(seconds, id: \.self) { index in
//                    Text("\(index)").tag(index)
//                        .font(.title3)
//                        .frame(width: 30, alignment: .trailing)
//                        .offset(x: -22)
//                }
//            } label: {
//                Text("Seconds")
//            }
//            .pickerStyle(.wheel)
//            .labelsHidden()
//
//            Text("sec")
//                .font(.headline)
//                .frame(width: 50, alignment: .leading)
//                .offset(x: 20)
//        }
//    }
    
    private func getPickerDurationAsSeconds() -> Double {
        var duration: Double = 0
        
        duration += Double(selections[0] * 3600)
        duration += Double(selections[1] * 60)
        duration += Double(selections[2])
        
        return duration
    }
}

//extension UIPickerView {
//    
//    open override var intrinsicContentSize: CGSize {
//        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
//    }
//}
