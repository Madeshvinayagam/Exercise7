//
//  ViewController.swift
//  Exercise7
//
//  Created by user237599 on 3/17/24.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        MapView.delegate = self
    }
    
    @IBAction func startTripButton(_ sender: Any) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        MapView.showsUserLocation = true
        tripView.backgroundColor = UIColor.systemGreen
    }
    
    @IBAction func stopTripButton(_ sender: Any) {
        
        locationManager.stopUpdatingLocation()
        MapView.showsUserLocation = false
        tripView.backgroundColor = UIColor.systemGray
    }
    
    
    @IBOutlet weak var currentSpeed: UILabel!
    
    @IBOutlet weak var maxSpeed: UILabel!
    
    @IBOutlet weak var averageSpeed: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var maxAcceleration: UILabel!
    
    
    @IBOutlet weak var exceededView: UIView!
    
    
    @IBOutlet weak var MapView: MKMapView!
    
    @IBOutlet weak var tripView: UIView!
    
    
    var startLocation : CLLocation!
    var lastLocation : CLLocation!
    var traveledDistance : Double = 0
    var previousSpeed : Double = 0
    var maxAccelerationValue : Double = 0
    var previousTime : Date? = Date()
    var speedsArray:[Double] = []
    let locationManager : CLLocationManager = CLLocationManager()
    
    var distanceBeforeExceedingDisplayed = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations[0]

        manager.startUpdatingLocation()

        render(location)

        if startLocation == nil{

            startLocation = locations.first!
        }
        else{

            let lastLocation = locations.last!
            let distance = startLocation.distance(from: lastLocation)
            startLocation = lastLocation
            traveledDistance = traveledDistance + distance;
        }

    if (location.speed * 3.6) > 115 && !distanceBeforeExceedingDisplayed {
        
        //To display the Distance of Travel Before Exceeding the Speed
        print("Driver Travels Before Exceeding the Speed limit : \(round(traveledDistance * 100 / 1000) / 100.0) km !")
        
        distanceBeforeExceedingDisplayed = true
    }
        //Display Distance
        distance.text = "\(round(traveledDistance*100/1000)/100.0) km"

        //Display Current Speed
        currentSpeed.text = "\(String(format: "%.2f", location.speed * 3.6)) km/h"

        speedsArray.append(location.speed*3.6)

        //Display Maximum Speed
        maxSpeed.text = "\(String(format: "%.2f", speedsArray.max() ?? 0)) km/h"

        var totalSpeed : Double = 0.0

        speedsArray.forEach{ speed in
            totalSpeed = totalSpeed + speed
        }

        let avgSpeedMeasured = totalSpeed/Double(speedsArray.count)

        if(previousSpeed != 0){

            let speedDifference = location.speed - previousSpeed
            
            let timeDifference = Date().timeIntervalSince(previousTime!)
            
            let acceleration = speedDifference/timeDifference
           
            maxAccelerationValue =  max(acceleration, maxAccelerationValue)
            
            //To display the maximum acceleration
            
            maxAcceleration.text = String (format : "%.3f", maxAccelerationValue) + " m/s^2"
        }

        previousSpeed = location.speed

        previousTime = Date()

        //To display the average speed
        
        averageSpeed.text = "\(String(format: "%.2f", avgSpeedMeasured)) km/h"

        exceededView.backgroundColor = (location.speed * 3.6) > 115 ? UIColor.red : UIColor.white

    }

    func render (_ location: CLLocation) {

           let coordinate = CLLocationCoordinate2D (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude )

           let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta:0.05)

           let region = MKCoordinateRegion(center: coordinate, span: span)

           let pin = MKPointAnnotation ()

           pin.coordinate = coordinate

        MapView.addAnnotation(pin)

        MapView.setRegion(region, animated: true)

       }
}

