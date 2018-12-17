//
//  ViewController.swift
//  mapView
//
//  Created by henry on 16/12/2018.
//  Copyright © 2018 HenryNguyen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    let locationManager = CLLocationManager()
    let regionInMeters : Double = 10000
    var previousLocation: CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imgPin: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationService()
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    //MARK: - Zoom in
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationService(){
        if CLLocationManager.locationServicesEnabled(){
            // set up location manager
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            //alert to user know they have to turn this on
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            //Do Map Stuff
         startTrackingUserLocation()
        case .denied:
            // alert let them know hoe to turn on location permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //show an alert let them know What's up?
            break
        case .authorizedAlways:
            break
        }
    }
    
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        //guard to make sure previousLocation has value
        guard let previousLocation = self.previousLocation else {return}
        
        guard center.distance(from: previousLocation) > 60 else {return}
        self.previousLocation = center // assign oldLocation  to newLocation
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else {return }
            
            if let _ = error{
                // TODO: show the alert informing users
                return
            }
            
            guard let placemark = placemarks?.first  else {
                //TODO: alert to user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? "" // --> ?? "" means providing default value
            let streetName = placemark.thoroughfare ?? ""
            
            // being inside the Closure --> Jump back to main thread
            DispatchQueue.main.async {
                self.lblAddress.text = "\(streetNumber) \(streetName)"
            }
        }
    }
}
