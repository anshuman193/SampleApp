//
//  MapViewController.swift
//  SampleApp
//
//  Created by Anshuman Singh on 8/23/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Cocoa
import MapKit
import SwiftyJSON


class MapViewController: GenericViewController<ViewControllerType.Type>, PareserDataUpdateDelegate {
 
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var currLocationButton: NSButton!
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    private let defaults = UserDefaults.standard
    

    private var baseUrl: String? {
        return Utility.readValue(fromplistFile: "Config", forKey: "BaseURL")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        loadCoordinatesFromDefaults()
        populateLastKnownCoordinates(lat: latitude, long: longitude)
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapClicked))
        mapView.addGestureRecognizer(recognizer)
        
        loadDataFromRemoteServer()
        
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        captureUserLocation()
        Logger.debugLog("viewWillDisappear")
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    private func loadCoordinatesFromDefaults(){
        
        latitude = defaults.double(forKey: "latitude")
        longitude = defaults.double(forKey: "longitude")
    }
    
    fileprivate func updateDefaults(_ annotation: MKAnnotation) {
        defaults.set(annotation.coordinate.latitude, forKey: "latitude")
        defaults.set(annotation.coordinate.longitude, forKey: "longitude")
    }
    
    private func captureUserLocation() {
        
        let annotation = mapView.annotations[0]
        updateDefaults(annotation)
        Logger.debugLog("captured user location latitude \(annotation.coordinate.latitude)")
        Logger.debugLog("captured user location longitude \(annotation.coordinate.longitude)")
    }
    
    private func populateLastKnownCoordinates(lat: Double, long: Double){
        let anno = MKPointAnnotation()
        anno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        mapView.addAnnotation(anno)
    }
    
    @objc private func mapClicked(recognizer: NSClickGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        
        let location = recognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        pinAnnotation(at: coordinate)
    }
    
    private func pinAnnotation(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Your location"
        mapView.addAnnotation(annotation)
    }
    
    
    fileprivate func loadDataFromRemoteServer() {
        
        if let baseurl = baseUrl, let webServiceHandler = WebServiceHandler(with:baseurl, latitude: latitude, longitude: longitude, parserDelegate: self) {
            webServiceHandler.fetchData()
        }
    }
    
    @IBAction func currLocationButtonAction(_ sender: Any){
        
        Logger.debugLog("current location button clicked")
    }
    
    
    //MARK:PareserDataUpdateDelegate
    
    func newDataDidBecomeAvaialble(model: CurrentWeatherInfo) {
        Logger.debugLog("newDataDidBecomeAvaialble")
        UIHandler.shared.updateSubmenuItems(model: model)
    }

}

