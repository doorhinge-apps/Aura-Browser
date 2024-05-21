//
//  WeatherWidgetView.swift
//  Aura
//
//  Created by Caedmon Myers on 13/5/24.
//

import SwiftUI
import WeatherKit

struct WeatherWidgetView: View {
    @ObservedObject var weatherKitManager = WeatherKitManager()
    
    @StateObject var locationDataManager = LocationDataManager()
    
    let myFormatter = MeasurementFormatter()
    
    var body: some View {
        if locationDataManager.authorizationStatus == .authorizedWhenInUse || locationDataManager.authorizationStatus == .authorizedAlways {
            GeometryReader { geo in
                VStack {
                    HStack(alignment: .center, content: {
                        Image(systemName: weatherKitManager.weather?.currentWeather.symbolName ?? "xmark")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .padding(10)
                        
                        Text(Int(weatherKitManager.weather?.currentWeather.temperature.value.rounded() ?? 0.0).description)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    })
                    
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 3)
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        
                        ForEach(weatherKitManager.weather?.hourlyForecast.forecast.prefix(5) ?? [], id:\.self.date) { hourWeather in
                            VStack {
                                Image(systemName: hourWeather.symbolName)
                                    .font(.system(size: geo.size.width/8, weight: .bold, design: .rounded))
                                    .frame(width: geo.size.width/8, height: geo.size.width/8)
                                
                                Text(Int(hourWeather.temperature.value.rounded()).description)
                            }
                            
                            Spacer()
                        }
                    }.padding(.vertical, 15)
                    
                    Text(geo.size.width.description)
                }
                .foregroundStyle(Color.white)
                .task {
                    await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                }
            }
            
            //Label(weatherKitManager.temp, systemImage: weatherKitManager.symbol)
        } else {
            Text("Error Loading Location")
        }
    }
}
