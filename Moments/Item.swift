//
//  Item.swift
//  Moments
//
//  Created by TaiPV on 14/3/26.
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
