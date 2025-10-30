//
//  Item.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 30/10/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
