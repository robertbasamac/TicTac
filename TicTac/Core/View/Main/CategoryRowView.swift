//
//  CategoryRowView.swift
//  TicTac
//
//  Created by Robert Basamac on 12.10.2022.
//

import SwiftUI

struct CategoryRowView: View {
    
    let category: CategoryModel?
    let selectedCategory: CategoryModel?
    
    var body: some View {
        HStack(spacing: 0) {
            if let category = category {
                Circle()
                    .foregroundColor(category.color)
                    .frame(width: 8, height: 8)
                    .frame(minWidth: 30)
            }
            
            Text(category?.title ?? "None")
            
            Spacer()
            
            if selectedCategory == category {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }
}

struct CategoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                CategoryRowView(category: dev.category, selectedCategory: dev.category)
            }
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
