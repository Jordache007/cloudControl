//
//  UserLocation.swift
//  CloudControl
//
//  Created by Duran Govender on 2024/06/22.
//

import Foundation
import CoreLocation

class UserLocation: NSObject, CLLocationManagerDelegate {
    static let shared = UserLocation()
    private let manager = CLLocationManager()
    var completion: ((CLLocation) -> Void)?
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    public func getUserLocation(completion: @escaping (CLLocation) -> Void) {
        self.completion = completion
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        completion?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
}

