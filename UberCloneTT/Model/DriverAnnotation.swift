//
//  DriverAnnotation.swift
//  UberCloneTT
//
//  Created by Jonathan Agarrat on 4/2/20.
//  Copyright © 2020 Jonathan Agarrat. All rights reserved.
//

import MapKit


class DriverAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
}
