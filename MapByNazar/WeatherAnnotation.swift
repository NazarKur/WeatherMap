//
//  WeatherAnnotation.swift
//  MapByNazar
//
//  Created by Nazar Kuradovets on 2/14/17.
//  Copyright © 2017 AdminAccount. All rights reserved.
//

import UIKit
import MapKit

class WeatherAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var color: UIColor = .purple
    
    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
}
