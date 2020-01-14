//
//  ViewController.swift
//  C0766598_labassignment1
//
//  Created by Rizul goyal on 2020-01-14.
//  Copyright © 2020 Rizul goyal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    enum transporttype : String
    {
        case automobile
        case walking
        
    }

    
    
    
    
    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
         
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
        let gestureDoubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        gestureDoubleTap.numberOfTapsRequired = 2
                          mapView.addGestureRecognizer(gestureDoubleTap)
         
         
    }
    
    @IBAction func buttonNavigation(_ sender: UIButton) {
            
            
         let otherAlert = UIAlertController(title: "Transport Type", message: "Please choose one Transport Type.", preferredStyle: UIAlertController.Style.actionSheet)

             

              let walkingbutton = UIAlertAction(title: "Walking", style: UIAlertAction.Style.default, handler: walkingHandler)
              
              let autobutton = UIAlertAction(title: "Automobile", style: UIAlertAction.Style.default, handler: autoHandler)


                  

                  // relate actions to controllers
                  otherAlert.addAction(walkingbutton)
                  otherAlert.addAction(autobutton)

            present(otherAlert, animated: true, completion: nil)
            

          
            
         

            
        }
        
       


    
    
     

        
        @objc func doubleTap(gestureRecognizer : UILongPressGestureRecognizer)
        {
            //remove annotations
            let i = mapView.annotations.count
            if i != 0
            {
            let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
            mapView.removeAnnotations( annotationsToRemove )
            }
            
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.title = "Latitude:\(coordinate.latitude)"
            annotation.subtitle = "Longitude:\(coordinate.longitude)"
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            //grab user location
           
            
            let userLocation : CLLocation = locations[0]
            let lat = userLocation.coordinate.latitude
           let long = userLocation.coordinate.longitude
            //define delta (difference) of lat and long
            let latDelta : CLLocationDegrees = 0.05
           let longDelta : CLLocationDegrees = 0.05

    //        //define span
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
    //
    //
    //        //define location
            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
    //
    //        //define region
            let region = MKCoordinateRegion(center: location, span: span)
    //
    //        // set the region on the map
           mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
            
//            let annotation = MKPointAnnotation()
//            annotation.title = "You are here"
//           annotation.coordinate = userLocation.coordinate
//            mapView.addAnnotation(annotation)
//
           
            
            
            //find the user address from his location
            //CLGeocoder().reverseGeocodeLocation()
        }
    
    func findroute(user: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, route: transporttype)
    {
        
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: user, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        
        if route.rawValue == "automobile"
        {
            request.transportType = .walking

        }
        else if route.rawValue == "walking"
        {
            request.transportType = .automobile
        }
        

        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.delegate = self
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
    }
        
    }
    
    
    
    func walkingHandler(alert: UIAlertAction){
        
        let currentlocation = mapView.userLocation
                 let currentlocationcoordinates = CLLocationCoordinate2D(latitude: currentlocation.coordinate.latitude, longitude: currentlocation.coordinate.longitude)
                 let destinationlocation = mapView.annotations
                 let destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destinationlocation[0].coordinate.latitude, longitude: destinationlocation[0].coordinate.longitude)
                 print(String(currentlocationcoordinates.latitude) + " Longitude " + String(currentlocationcoordinates.longitude))
                 print(String(destinationlocationcoordinates.latitude) + " Longitude " + String(destinationlocationcoordinates.longitude))
                 
        findroute(user: currentlocationcoordinates, destination: destinationlocationcoordinates, route: .walking)
        
        
                    // print("You tapped: \(alert.title)")
                 }

       func autoHandler(alert: UIAlertAction){
        
        let currentlocation = mapView.userLocation
                 let currentlocationcoordinates = CLLocationCoordinate2D(latitude: currentlocation.coordinate.latitude, longitude: currentlocation.coordinate.longitude)
                 let destinationlocation = mapView.annotations
                 let destinationlocationcoordinates = CLLocationCoordinate2D(latitude: destinationlocation[0].coordinate.latitude, longitude: destinationlocation[0].coordinate.longitude)
                 print(String(currentlocationcoordinates.latitude) + " Longitude " + String(currentlocationcoordinates.longitude))
                 print(String(destinationlocationcoordinates.latitude) + " Longitude " + String(destinationlocationcoordinates.longitude))
                 
        findroute(user: currentlocationcoordinates, destination: destinationlocationcoordinates, route: .automobile)
                   // print("You tapped: \(alert.title)")
                }
    
   


}




extension ViewController : MKMapViewDelegate
   {
       
       func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
           renderer.strokeColor = UIColor.blue
           return renderer
       }
   }

