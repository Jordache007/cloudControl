//
//  APIClient.swift
//  CloudControl
//
//  Created by Duran Govender on 2024/06/22.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    private let apiKey = "1c45fd2275cf210b59cff89dc4fac546"
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let forecastURL = "https://api.openweathermap.org/data/2.5/forecast"
    
    
    private init() {}
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchForecast(lat: Double, lon: Double, completion: @escaping (Result<ForecastResponse, Error>) -> Void) {
        let urlString = "\(forecastURL)?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            print("Duran-->\(urlString)")
            return
        }
        
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
                completion(.success(forecastResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
