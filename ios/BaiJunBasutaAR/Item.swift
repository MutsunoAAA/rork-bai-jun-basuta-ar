//
//  Item.swift
//  BaiJunBasutaAR
//
//  Created by Rork on March 28, 2026.
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
