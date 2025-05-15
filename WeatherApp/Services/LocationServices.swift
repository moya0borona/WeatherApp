//
//  LocationServices.swift
//  WeatherApp
//
//  Created by Андрей Андриянов on 14.05.2025.
//

import Foundation
import CoreLocation

protocol CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation)
}

class LocationServices: NSObject, CLLocationManagerDelegate {
   
    public static let shared = LocationServices()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    private let concurrentQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    var userLocationDelegate: CustomUserLocationDelegate?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        concurrentQueue.sync {
            currentLocation = manager.location?.coordinate
            
            if userLocationDelegate != nil {
                userLocationDelegate!.userLocationUpdated(location: locations.first!)
            }
        }
    }
}
