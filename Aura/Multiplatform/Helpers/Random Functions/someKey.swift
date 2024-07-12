//
//  someKey.swift
//  Aura
//
//  Created by Reyna Myers on 10/7/24.
//

import SwiftUI

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
