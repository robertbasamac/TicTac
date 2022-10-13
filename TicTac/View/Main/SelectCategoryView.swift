//
//  SelectCategoryView.swift
//  TicTac
//
//  Created by Robert Basamac on 12.10.2022.
//

import SwiftUI

struct SelectCategoryView: View {
    @EnvironmentObject private var tm: TimerManager
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var category: CategoryModel
    
    var body: some View {
        Form {
            Section {
                NavigationLink {
                    CreateCategoryView()
                } label: {
                    Text("Create New Category")
                }
            }
            
            Section {
                ForEach(tm.categories) { category in
                    categoryRowView(category: category)
                        .onTapGesture {
                            self.category = category
                        }
                }
            } header: {
                if !tm.categories.isEmpty {
                    Text("Categories")
                }
            }
        }
        .navigationTitle("Category")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func categoryRowView(category: CategoryModel) -> some View {
        HStack(spacing: 0) {
            Circle()
                .foregroundColor(category.color)
                .frame(width: 8, height: 8)
                .frame(minWidth: 30)
            
            Text(category.title)
            
            Spacer()
            
            if category == self.category {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }
}

struct SelectCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectCategoryView(category: .constant(dev.category))
                .environmentObject(dev.tm)
        }
    }
}
