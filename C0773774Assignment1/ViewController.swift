//
//  ViewController.swift
//  C0773774Assignment1
//
//  Created by Nitin on 14/01/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK:- Properties
    @IBOutlet var subBtn: UIButton!
    @IBOutlet var segmentBtn: UISegmentedControl!
    @IBOutlet var addBtn: UIButton!
    @IBOutlet var mapview: MKMapView!
    @IBOutlet var editView: UIView!
    
    private var locationManager = CLLocationManager()
    var sourCoord = CLLocationCoordinate2D()
    var desCoord = CLLocationCoordinate2D()
    
    var moveType: String = "A"
    
    // MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        editView.isHidden = true

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()


        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //
        setRegion()
        
        // add long press gesture
        let uitpgr = UITapGestureRecognizer(target: self, action: #selector(tappress))
        uitpgr.numberOfTapsRequired = 2
        mapview.addGestureRecognizer(uitpgr)
        
    }
    
    // MARK:- Helper
    func setRegion(){
        // Define latitude and longitude
        let latitude:CLLocationDegrees = 43.64
        let longitude:CLLocationDegrees = -79.38
        
        // Define delta latitude and longitude
        let latDelta:CLLocationDegrees = 0.5
        let longDelta:CLLocationDegrees = 0.5
        
        // Define span
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        // define location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // define region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // set the region on the map
        mapview.setRegion(region, animated: true)
        
        mapview.delegate = self
        mapview.showsUserLocation = true
    }
    
    @objc func tappress(gestureRecognizer: UIGestureRecognizer){
        //removes annotations
        mapview.removeAnnotations(mapview.annotations)
        
        
        // remove previous overlays
        let overlays = mapview.overlays
        mapview.removeOverlays(overlays)
        
        // draw annotation
        let touchPoint = gestureRecognizer.location(in: mapview)
        desCoord = mapview.convert(touchPoint, toCoordinateFrom: mapview)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Destination"
        annotation.coordinate = desCoord
        mapview.addAnnotation(annotation)
    }
    
    // MARK:- Action
    @IBAction func zoomInBtnClicked(_ sender: Any) {
        let span = MKCoordinateSpan(latitudeDelta: mapview.region.span.latitudeDelta/2, longitudeDelta: mapview.region.span.longitudeDelta/2)
        let region = MKCoordinateRegion(center: mapview.region.center, span: span)

        mapview.setRegion(region, animated: true)
    }
    
    @IBAction func zoomOutBtnClicked(_ sender: Any) {
        let span = MKCoordinateSpan(latitudeDelta: mapview.region.span.latitudeDelta*2, longitudeDelta: mapview.region.span.longitudeDelta*2)
         let region = MKCoordinateRegion(center: mapview.region.center, span: span)

         mapview.setRegion(region, animated: true)
    }
    
    @IBAction func segmentClicked(_ sender: UISegmentedControl) {
        
        // remove previous overlays
        let overlays = mapview.overlays
        mapview.removeOverlays(overlays)
        
        if sender.selectedSegmentIndex == 0 {
            moveType = "A"
        }else{
            moveType = "W"
        }
        
    }
    
    @IBAction func moreBtnClicked(_ sender: Any) {
        if(editView.isHidden == true){
            editView.isHidden = false
            
        }else{
            editView.isHidden = true
            
        }
    }
    
    @IBAction func mapBtnClicked(_ sender: Any) {
        // remove previous overlays
        let overlays = mapview.overlays
        mapview.removeOverlays(overlays)
        
        // draw route
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourCoord, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: desCoord, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        if(moveType == "A"){
            request.transportType = .automobile
        }else{
            request.transportType = .walking
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            let route = unwrappedResponse.routes[0]
            self.mapview.addOverlay(route.polyline)
            self.mapview.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//            for route in unwrappedResponse.routes {
//                self.mapview.addOverlay(route.polyline)
//                self.mapview.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//            }
        }
        
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        sourCoord = locValue
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    //
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //        if annotation is MKUserLocation {
    //            return nil
    //        }else {
    //            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
    //            annotationView.image = UIImage(named: "ic_place")
    //            annotationView.canShowCallout = true
    //            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    //
    //            return annotationView
    //        }
    //    }
    
//
    
    
    
    /// this function is needed to add overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 2.0
            return renderer
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3.0
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2.0
            return renderer
        }
        
        return MKOverlayRenderer()
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Welcome tp \(title)", message: "Have a good time in \(title)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
}


