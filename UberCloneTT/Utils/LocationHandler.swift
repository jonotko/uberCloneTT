//
//  LocationHandler.swift
//  UberCloneTT
//
//  Created by Jonathan Agarrat on 4/1/20.
//  Copyright © 2020 Jonathan Agarrat. All rights reserved.
//

import CoreLocation


class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?
    
    override init() {
        super.init()
        print("DEBUG: Initialized Location Delegate")
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
        
    }
}
