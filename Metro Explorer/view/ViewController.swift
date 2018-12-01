//
//  ViewController.swift
//  Metro Explorer
//
//  Created by heran zhao on 11/17/18.
//  Copyright © 2018 heran zhao. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    var locationManager: CLLocationManager!
    var curLon : Double = 0
    var curLat: Double = 0
    
    var isFinding = false
    var getLocation = false
    
    let TAG = "ViewController"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        isFinding = false
        getLocation = false
    }
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "nearestSegue", sender: "Favorite")

    }
    @IBAction func nearestButtonPressed(_ sender: Any) {
        
        if(!isFinding)
        {
            isFinding = true
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            
            if (CLLocationManager.locationServicesEnabled())
            {
                locationManager.requestLocation()
            }
            else
            {
                let message = "Please check your network or location setting."
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                self.present(alert, animated: true)
                let duration: Double = 1.5
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                    alert.dismiss(animated: true)
                }
                isFinding = false
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nearestSegue"{
            
            let vc = segue.destination as! LandmarksViewController
            
            switch sender as! String
            {
            case "Nearest":
                vc.type = LandmarksViewController.LandmarkViewType.Nearest
            case "Favorite":
                vc.type = LandmarksViewController.LandmarkViewType.Favorite
            default:
                return
            }
            
        }
    }
}

extension ViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        
        curLon = userLocation.coordinate.longitude
        curLat = userLocation.coordinate.latitude
        
        if(!getLocation)
        {
            getLocation = true
            MetroStationAPIManager.shared.delegate = self
            MetroStationAPIManager.shared.fetchStations()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        isFinding = false
        getLocation = false
        
        let message = "Please allow the location permission in setting."
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)
        let duration: Double = 1.5
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
        isFinding = false
    }
}

extension ViewController : FetchStationsDelegate
{
    func stationFound()
    {
        MetroStationAPIManager.shared.setNearestStation(curLat, curLon)
        DispatchQueue.main.async {
            if(self.TAG == "ViewController")
            {
                self.performSegue(withIdentifier: "nearestSegue", sender: "Nearest")
            }
        }
    }
    
    
    func stationNotFound() {
        isFinding = false
        getLocation = false
        DispatchQueue.main.async {
            let message = "Network Error, please try again later."
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)
            let duration: Double = 1.5
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
            }
        }
    }
}
