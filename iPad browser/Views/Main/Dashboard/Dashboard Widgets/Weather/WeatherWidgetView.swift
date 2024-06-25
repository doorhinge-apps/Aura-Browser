//
//  WeatherWidgetView.swift
//  Aura
//
//  Created by Caedmon Myers on 13/5/24.
//

import SwiftUI
import WeatherKit

struct WeatherWidgetView: View {
    @StateObject var weatherKitManager = WeatherKitManager()
    
    @StateObject var locationDataManager = LocationDataManager()
    
    let myFormatter = MeasurementFormatter()
    
    @State var highTemp = -1000.0
    @State var lowTemp = 1000.0
    
    var body: some View {
        if locationDataManager.authorizationStatus == .authorizedWhenInUse {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            VStack {
                                HStack(alignment: .center, content: {
                                    Image(systemName: weatherKitManager.weather?.currentWeather.symbolName ?? "xmark")
                                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                        .padding(.trailing, 10)
                                    
                                    Text(convertToPrefferedUnits(inputTemp: weatherKitManager.weather?.currentWeather.temperature.value ?? 0.0) + "°")
                                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                })
                                
                                HStack(spacing: 0) {
                                    Spacer()
                                    
                                    ForEach(weatherKitManager.weather?.hourlyForecast.forecast.prefix(geo.size.width > 200 ? 5: 4) ?? [], id: \.date) { hourWeather in
                                        VStack {
                                            Text(hourWeather.date.formatted(.dateTime.hour()).prefix(geo.size.width > 200 ? 5: 2).replacingOccurrences(of: geo.size.width > 200 ? "": " ", with: ""))
                                                .font(.system(geo.size.width <= 200 ? .caption: .body, design: .rounded, weight: .bold))
                                                .opacity(0.4)
                                            
                                            Image(systemName: hourWeather.symbolName)
                                                .font(.system(geo.size.height < 250 ? .body: .title2, design: .rounded, weight: .bold))
                                            
                                            Text(convertToPrefferedUnits(inputTemp: hourWeather.temperature.value))
                                                .font(.system(geo.size.width <= 200 ? .caption2: .body, design: .rounded, weight: .regular))
                                        }
                                        
                                        Spacer()
                                    }
                                }.padding(.top, 5)
                            }
                            
                            if geo.size.width > 350 {
                                Divider()
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(weatherKitManager.weather?.currentWeather.condition.description ?? "")
                                            .font(.system(.title, design: .rounded, weight: .bold))
                                        
                                        Spacer()
                                            .frame(height: 20)
                                        
                                        Text("Wind:")
                                            .font(.system(.headline, design: .rounded, weight: .bold))
                                            .opacity(0.8)
                                        Text("\(weatherKitManager.weather?.currentWeather.wind.speed.description ?? "")")
                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                        Text("\(weatherKitManager.weather?.currentWeather.wind.compassDirection.description ?? "")")
                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                    }
                                    
                                    Spacer()
                                }.frame(width: 150)
                            }
                        }
                        
                        if geo.size.height >= 250 {
                            Divider()
                            
                            HStack {
                                VStack {
                                    ForEach(weatherKitManager.weather?.dailyForecast.forecast.prefix(4) ?? [], id: \.date) { dailyWeather in
                                        HStack {
                                            Text(dailyWeather.date.formatted(.dateTime.weekday(.wide)).description.prefix(3))
                                            
                                            Spacer()
                                            
                                            Image(systemName: dailyWeather.symbolName ?? "xmark")
                                                .font(.system(.body, design: .rounded, weight: .bold))
                                            
                                            Spacer()
                                            
                                            Text(Int(dailyWeather.lowTemperature.value.rounded()).description)
                                                .opacity(0.4)
                                            
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .opacity(0.2)
                                                    .frame(height: 6)
                                                    .frame(width: 100)
                                                
                                                HStack(spacing: 0) {
                                                    Spacer()
                                                        .frame(width: CGFloat((100.0 / (highTemp - lowTemp)) * ((dailyWeather.lowTemperature.value ?? 0.0) - lowTemp)))
                                                    
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(createWeatherGradient(low: 0, high: 30))
                                                        .frame(width: (100.0 / (highTemp - lowTemp)) * ((dailyWeather.highTemperature.value ?? 0.0) - (dailyWeather.lowTemperature.value ?? 0.0)), height: 6)
                                                    
                                                    Spacer()
                                                }
                                                
                                                if dailyWeather.date.formatted(.dateTime.dayOfYear()) == Date.now.formatted(.dateTime.dayOfYear()) {
                                                    HStack(spacing: 0) {
                                                        Circle()
                                                            .frame(width: 8)
                                                            .offset(x: CGFloat((100.0 / (highTemp - lowTemp)) * ((weatherKitManager.weather?.currentWeather.temperature.value ?? 0.0) - lowTemp)))
                                                            .offset(x: -8)
                                                            .onAppear() {
                                                                print("High: \(highTemp) Low: \(lowTemp)")
                                                                print((100.0 / (highTemp - lowTemp)) * ((weatherKitManager.weather?.currentWeather.temperature.value ?? 0.0) - lowTemp))
                                                            }
                                                        
                                                        Spacer()
                                                    }
                                                }
                                            }.frame(width: 100)
                                            
                                            Text(Int(dailyWeather.highTemperature.value.rounded()).description)
                                        }
                                    }
                                }.padding([.leading, .trailing], 15)
                                
                                if geo.size.width > 350 {
                                    Divider()
                                    
                                    VStack {
                                        ForEach(weatherKitManager.weather?.dailyForecast.forecast.prefix(8).suffix(4) ?? [], id: \.date) { dailyWeather in
                                            HStack {
                                                Text(dailyWeather.date.formatted(.dateTime.weekday(.wide)).description.prefix(3))
                                                
                                                Spacer()
                                                
                                                Image(systemName: dailyWeather.symbolName ?? "xmark")
                                                    .font(.system(.body, design: .rounded, weight: .bold))
                                                
                                                Spacer()
                                                
                                                Text(Int(dailyWeather.lowTemperature.value.rounded()).description)
                                                    .opacity(0.4)
                                                
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .opacity(0.2)
                                                        .frame(height: 6)
                                                        .frame(width: 100)
                                                    
                                                    HStack(spacing: 0) {
                                                        Spacer()
                                                            .frame(width: CGFloat((100.0 / (highTemp - lowTemp)) * ((dailyWeather.lowTemperature.value ?? 0.0) - lowTemp)))
                                                        
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(createWeatherGradient(low: 0, high: 30))
                                                            .frame(width: (100.0 / (highTemp - lowTemp)) * ((dailyWeather.highTemperature.value ?? 0.0) - (dailyWeather.lowTemperature.value ?? 0.0)), height: 6)
                                                        
                                                        Spacer()
                                                    }
                                                    
                                                    if dailyWeather.date.formatted(.dateTime.dayOfYear()) == Date.now.formatted(.dateTime.dayOfYear()) {
                                                        HStack(spacing: 0) {
                                                            Circle()
                                                                .frame(width: 8)
                                                                .offset(x: CGFloat((100.0 / (highTemp - lowTemp)) * ((weatherKitManager.weather?.currentWeather.temperature.value ?? 0.0) - lowTemp)))
                                                                .offset(x: -8)
                                                                .onAppear() {
                                                                    print("High: \(highTemp) Low: \(lowTemp)")
                                                                    print((100.0 / (highTemp - lowTemp)) * ((weatherKitManager.weather?.currentWeather.temperature.value ?? 0.0) - lowTemp))
                                                                }
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                                }.frame(width: 100)
                                                
                                                Text(Int(dailyWeather.highTemperature.value.rounded()).description)
                                            }
                                        }
                                    }.padding([.leading, .trailing], 15)
                                }
                            }
                        }
                        
                    }
                    
                }.foregroundStyle(Color.white)
                    .task {
                        await fetchWeatherData()
                    }
            }
            
        } else {
            Text("Error Loading Location")
        }
    }
    
    func fetchWeatherData() async {
        await weatherKitManager.getWeather(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
        print(weatherKitManager.weather?.dailyForecast.forecast.prefix(8) ?? [])
        
        if let dailyForecast = weatherKitManager.weather?.dailyForecast.forecast.prefix(8) {
            let highTemperatures = dailyForecast.map { $0.highTemperature.value }
            if let maxHighTemp = highTemperatures.max() {
                highTemp = maxHighTemp
            }
        }
        
        if let dailyForecast = weatherKitManager.weather?.dailyForecast.forecast.prefix(8) {
            let lowTemperatures = dailyForecast.map { $0.lowTemperature.value }
            if let minLowTemp = lowTemperatures.min() {
                lowTemp = minLowTemp
            }
        }
    }
}


func createWeatherGradient(low: Double, high: Double) -> LinearGradient {
    let colorMapping: [(value: Double, color: Color)] = [
        (-20, Color(hex: "5F32BC")),
        (-10, Color(hex: "4241FF")),
        (0, Color(hex: "41C6FF")),
        (10, Color(hex: "08BD50")),
        (20, Color(hex: "ECE94D")),
        (30, Color(hex: "ECA54D")),
        (40, Color(hex: "F74B42"))
    ]
    
    let filteredColors = colorMapping.filter { $0.value >= low && $0.value <= high }
    
    let boundaryColors = colorMapping.filter { $0.value == low || $0.value == high }
    
    let gradientColors = (filteredColors + boundaryColors).sorted { $0.value < $1.value }
    
    let gradientStops: [Gradient.Stop]
    if let firstColor = gradientColors.first, let lastColor = gradientColors.last {
        gradientStops = [
            Gradient.Stop(color: firstColor.color, location: 0),
            Gradient.Stop(color: firstColor.color, location: 0.001)
        ] + gradientColors.dropFirst().dropLast().map {
            Gradient.Stop(color: $0.color, location: CGFloat(($0.value - low) / (high - low)))
        } + [
            Gradient.Stop(color: lastColor.color, location: 0.999),
            Gradient.Stop(color: lastColor.color, location: 1)
        ]
    } else {
        gradientStops = []
    }
    
    return LinearGradient(
        gradient: Gradient(stops: gradientStops),
        startPoint: .leading,
        endPoint: .trailing
    )
}


func convertToPrefferedUnits(inputTemp: Double) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .medium
    formatter.numberFormatter.maximumFractionDigits = 0
    
    let measurement = Measurement(value: inputTemp, unit: UnitTemperature.celsius)
    let temperatureString = formatter.string(from: measurement)
    
    let temperatureComponents = temperatureString.components(separatedBy: CharacterSet.decimalDigits.inverted)
    if let numericPart = temperatureComponents.joined().isEmpty ? nil : temperatureComponents.joined(),
       let temperatureValue = Double(numericPart) {
        let roundedTemp = String(Int(temperatureValue.rounded()))
        return roundedTemp
    }
    
    return "0"
}
