//
//  WeatherParser.swift
//  MapByNazar
//
//  Created by Nazar Kuradovets on 2/14/17.
//  Copyright © 2017 AdminAccount. All rights reserved.
//

import UIKit

class WeatherParser: NSObject {
    
    var temperature : Double?
    var pressure : Double?
    var cityName: String?
    var windspeed: Double?
    var weatherIcon: UIImage?
    
    init(data : Data) {
        super.init()
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
}

extension WeatherParser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "temperature" {
            if let temperature = attributeDict["value"], let temperatureDouble = Double(temperature)  {
                self.temperature = temperatureDouble
            }
        }
        if elementName == "pressure" {
            if let pressure = attributeDict["value"], let pressureDouble = Double(pressure) {
                self.pressure = pressureDouble
                print("\(pressure)")
            }
        }
        
        if elementName == "city" {
            if let cityName = attributeDict["name"], let cityNameString = String(cityName) {
                self.cityName = cityNameString
                print("\(cityName)")
            }
        }
        
        if  elementName == "speed" {
            if let windspeed = attributeDict["value"], let windspeedDouble = Double(windspeed) {
                self.windspeed = windspeedDouble
                print("\(windspeed)")
            }
        }
    }
    
//        //FIX: - parse weather icon
//        if  elementName == "weather" {
//        if let weatherIcon = attributeDict["icon"], let weatherIconView = UIImage(weatherIcon) {
//            self.weatherIcon = weatherIconView
//            print("\(windspeed)")
//        }
//    }
}
