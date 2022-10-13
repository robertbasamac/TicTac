//
//  CategoryModel.swift
//  TicTac
//
//  Created by Robert Basamac on 12.10.2022.
//

import Foundation
import SwiftUI

struct CategoryModel: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var color: Color
}
