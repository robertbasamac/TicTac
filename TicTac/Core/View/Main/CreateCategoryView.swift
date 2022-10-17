//
//  CreateNewCategoryView.swift
//  TicTac
//
//  Created by Robert Basamac on 12.10.2022.
//

import SwiftUI

struct CreateCategoryView: View {
    @EnvironmentObject private var tm: TimerManager
    
    @Environment(\.dismiss) private var dismiss
        
    @State private var title: String = ""
    @State private var color: Color = Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Title")
                    
                    TextField("Category", text: $title)
                        .multilineTextAlignment(.trailing)
                }
                
                ColorPicker(selection: $color) {
                    Text("Color")
                }
            } header: {
                Text("New Category")
            }
        }
        .navigationTitle("Create New Category")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    tm.createCategory(category: CategoryModel(title: title, color: color))
                    dismiss()
                } label: {
                    Text("Save")
                }
                .disabled(isSaveButtonDisabled())
            }
        }
    }
    
    private func isSaveButtonDisabled() -> Bool {
        return title.isEmpty
    }
}

struct CreateNewCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateCategoryView()
                .environmentObject(TimerManager())
        }
    }
}
