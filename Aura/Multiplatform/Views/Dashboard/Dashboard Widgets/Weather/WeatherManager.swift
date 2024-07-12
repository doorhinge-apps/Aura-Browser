//
//  WeatherManager.swift
//  Aura
//
//  Created by Reyna Myers on 13/5/24.
//

import Foundation
import WeatherKit



@MainActor class WeatherKitManager: ObservableObject {
    
    @Published var weather: Weather?
    
    func getWeather(latitude: Double, longitude: Double) async {
        do {
            weather = try await Task.detached(priority: .userInitiated) {
                return try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))
            }.value
        } catch {
            fatalError("\(error)")
        }
    }
    
    var symbol: String {
        weather?.currentWeather.symbolName ?? "xmark"
    }
    
    var temp: String {
        let temp =
        weather?.currentWeather.temperature.value
        
        let myFormatter = MeasurementFormatter()
        let temperature = Measurement(value: temp ?? 0.0, unit: UnitTemperature.celsius)
        
        
        //let convert = temp?.converted(to: .fahrenheit).description
        return myFormatter.string(from: temperature)//convert ?? "Loading Weather Data"
        
    }
    
}
