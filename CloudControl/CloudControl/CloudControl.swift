//
//  CloudControl.swift
//  CloudControl
//
//  Created by Duran Govender on 2024/06/23.
//

import Foundation
import CoreLocation

class CloudControl: NSObject, CLLocationManagerDelegate {
    
    var forecastData: [Forecast] = []
    var weatherResponse: WeatherResponse?
        
        func fetchForecast(lat: Double, lon: Double, completion: @escaping (Result<Void, Error>) -> Void) {
            APIClient.shared.fetchForecast(lat: lat, lon: lon) { result in
                switch result {
                case .success(let forecastResponse):
                    let calendar = Calendar.current
                    let today = Date()
                    let currentWeek = calendar.dateInterval(of: .weekOfYear, for: today)
                    
                    self.forecastData = forecastResponse.list.filter { forecast in
                        guard let date = self.date(from: forecast.dt_txt) else { return false }
                        return currentWeek?.contains(date) ?? false
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    
    func fetchWeatherData(lat: Double, lon: Double, completion: @escaping (Result<Void, Error>) -> Void) {
            APIClient.shared.fetchWeather(lat: lat, lon: lon) { result in
                switch result {
                case .success(let weatherResponse):
                    self.weatherResponse = weatherResponse
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        
        private func date(from dateString: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.date(from: dateString)
        }
}
