//
//  NetworkMonitor.swift
//  Aura
//
//  Created by Reyna Myers on 10/7/24.
//

import SwiftUI
import Network

@Observable
class NetworkMonitor {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        networkMonitor.start(queue: workerQueue)
    }
}
