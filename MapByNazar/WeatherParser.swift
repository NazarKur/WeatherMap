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
    var iconDownloadCompletion : ((UIImage?) -> Void)?
    
    init(data : Data) {
        super.init()
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    fileprivate func  downloadConditionImage(stringUrl : String) {
        guard let urlAllowed = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: urlAllowed) else {
                print("Not valid URL")
                return
        }
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let downloadCompletion = self.iconDownloadCompletion {
                        downloadCompletion(UIImage(data: data!))
                    }
                    self.weatherIcon = UIImage(data: data!)
                }
            }
        })
        dataTask.resume()
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
            }
        }
        
        if elementName == "city" {
            if let cityName = attributeDict["name"], let cityNameString = String(cityName) {
                self.cityName = cityNameString
            }
        }
        
        if  elementName == "speed" {
            if let windspeed = attributeDict["value"], let windspeedDouble = Double(windspeed) {
                self.windspeed = windspeedDouble
            }
        }
        
        //FIX: - parse weather icon
        if  elementName == "weather" {
            if let weatherIcon = attributeDict["icon"] {
                let iconUrl = "http://openweathermap.org/img/w/\(weatherIcon).png"
                downloadConditionImage(stringUrl: iconUrl)
            }
        }
    }
}
