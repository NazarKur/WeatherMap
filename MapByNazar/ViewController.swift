//
//  ViewController.swift
//  MapByNazar
//
//  Created by Nazar Kuradovets on 2/13/17.
//  Copyright © 2017 AdminAccount. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - Parameters
    let session = URLSession(configuration: .default)
    let initialLatitude = 49.2327800
    let initialLongitude = 28.4809700
    let locationManager = CLLocationManager()
    var mapOverlay = MKTileOverlay()
    let googleMapUrl = "http://mt0.google.com/vt/x={x}&y={y}&z={z}"
    let temperatureUrl = "http://maps.owm.io:8099/5735d67f5836286b007625cd/{z}/{x}/{y}?hash=ba22ef4840c7fcb08a7a7b92bf80d1fc"
    let openStreetUrl = "http://c.tile.openstreetmap.org/{z}/{x}/{y}.png"
        
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var darkFillView: UIView!
    @IBOutlet weak var toggleMenuButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var windspeedLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    // MARK: - Change map type
    @IBAction func changeMapType(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
                mapView.remove(mapOverlay)
                mapOverlay.canReplaceMapContent = true
                mapView.mapType = MKMapType.standard
        case 1:
                mapView.remove(mapOverlay)
                mapOverlay = MKTileOverlay(urlTemplate: googleMapUrl)
                mapOverlay.canReplaceMapContent = true
                mapView.insert(mapOverlay, at: 0)
        case 2:
            mapView.remove(mapOverlay)
            mapOverlay = MKTileOverlay(urlTemplate: openStreetUrl)
            mapOverlay.canReplaceMapContent = true
            mapView.insert(mapOverlay, at: 0)
                    default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        let initialLocation = CLLocation(latitude: initialLatitude, longitude: initialLongitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, 1000000, 1000000)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.delegate = self
        self.mapView.showsUserLocation = true
        
    }
    
    // MARK: - Add temperature tile
    @IBAction func TemperatureButtonPressed(_ sender: UIButton) {
        
        mapOverlay = MKTileOverlay(urlTemplate: temperatureUrl)
        mapView.add(mapOverlay)

    }

    // MARK: - Add animations to toggleMenuButton
    @IBAction func toggleMenu(_ sender: UIButton) {
        if darkFillView.transform == CGAffineTransform.identity{
            UIView.animate(withDuration: 1, animations: {
                self.darkFillView.transform = CGAffineTransform(scaleX: 11, y: 11)
                self.menuView.transform = CGAffineTransform(translationX: 0,y: -95)
                self.toggleMenuButton.transform = CGAffineTransform(rotationAngle: self.radians(180))
            }) { (true) in
                
            }
        } else {
            UIView.animate(withDuration: 1, animations: {
                self.darkFillView.transform = .identity
                self.menuView.transform = .identity
                self.toggleMenuButton.transform = .identity
            })
        }
    }
    
    /// convert degrees to radians
    func radians(_ degrees: Double)-> CGFloat {
        return CGFloat(degrees * .pi / degrees)
    }
    
    // MARK: - Get users location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error:" + error.localizedDescription)
    }
    
    func parseTemperatureData(latitude: Double, longitude: Double, completionHandler: @escaping (_ data: Data) -> Void ) {
        let apiKey = "673af19414ae8463c8574fedc485c887"
        let string = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&mode=xml&APPID=\(apiKey)"
        let url = URL(string: string)
        let dataTask = session.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completionHandler(data!)
                }
            }
        })
        dataTask.resume()
    }
    
    // MARK: - Customizing pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? WeatherAnnotation {
            let identifier = "tempPin"
            var view : MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.animatesDrop = true
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -8, y: -5)
                view.pinTintColor = annotation.color
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
                //FIX: - need to parse icon to add it to leftAccessoryView
                let leftIconView = UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(30), height: CGFloat(30)))
                //                let imageString =  ()!
                view.leftCalloutAccessoryView = leftIconView
            }
            return view
        }
        return nil
    }
    
    // MARK: - Open menuView by tap on detailButton
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if darkFillView.transform == CGAffineTransform.identity{
            UIView.animate(withDuration: 1, animations: {
                self.darkFillView.transform = CGAffineTransform(scaleX: 11, y: 11)
                self.menuView.transform = CGAffineTransform(translationX: 0,y: -95)
                self.toggleMenuButton.transform = CGAffineTransform(rotationAngle: self.radians(180))
            }) { (true) in
                
            }
        }
    }
    
    // MARK: - Adding Overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKTileOverlay {
            let render = MKTileOverlayRenderer(tileOverlay: overlay)
            return render
        }
        return MKOverlayRenderer()
    }

    // MARK: - IBAction to handle longpress tap
    @IBAction func handleTap(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        parseTemperatureData(latitude: coordinate.latitude,
                             longitude: coordinate.longitude,
                             completionHandler: { (data) in
                                let parser = WeatherParser(data: data)
                                let annotation = WeatherAnnotation(title: String(parser.cityName!), subtitle: String(format: "%g C", parser.temperature!), leftIconView: parser.weatherIcon , coordinate: coordinate)
                                print("\(parser.weatherIcon)")
                                DispatchQueue.main.async {
                                    self.mapView.addAnnotation(annotation)
                                    self.windspeedLabel.text = String(format: "%g m/s", parser.windspeed!)
                                    self.pressureLabel.text = String(format: "%g hPa", parser.pressure!)
                                }
        })
    }
}
