//
//  WeatherDataModel.swift
//  WeatherApp
//
//  Created by Андрей Андриянов on 14.05.2025.
//

import Foundation

struct WeatherData: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}
struct Location: Codable {
    let name: String
    let region: String    
    let country: String
}
struct Current: Codable {
    let temp_c: Double
    let condition: Condition
    let last_updated: String
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let day: Day
    let hour: [Hour]
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: Condition
}

struct Hour: Codable {
    let time: String
    let temp_c: Double
    let condition: Condition
 
    var date: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: time)
    }
}

struct Condition: Codable {
    let text: String
    let icon: String
}

