//
//  Item.swift
//  EasyStream
//
//  Created by Pabel Andino on 8/6/26.
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
