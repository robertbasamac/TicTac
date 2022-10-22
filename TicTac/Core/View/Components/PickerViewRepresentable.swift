//
//  ContentView.swift
//  TicTac
//
//  Created by Robert Basamac on 11.10.2022.
//

import SwiftUI

struct PickerViewRepresentable: UIViewRepresentable {
    var data: [[String]]
    @Binding var selections: [Int]

    func makeCoordinator() -> PickerViewRepresentable.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<PickerViewRepresentable>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)

        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<PickerViewRepresentable>) {
        for i in 0...(self.selections.count - 1) {
            view.selectRow(self.selections[i], inComponent: i, animated: false)
        }
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PickerViewRepresentable

        init(_ pickerView: PickerViewRepresentable) {
            self.parent = pickerView
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return self.parent.data.count
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.parent.data[component].count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.parent.data[component][row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selections[component] = row
        }
    }
}
