//
//  MapViewController.swift
//  WeatherTracker
//
//  Created by Anshuman Singh on 8/23/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Cocoa
import MapKit
import CoreLocation

protocol MapViewObserver: class {
    
    func doneButtonClicked()
}

class MapViewController: NSViewController, PareserDataUpdateDelegate, WebServiceProtocol, AgentUICoordinatorProtocol, CLLocationManagerDelegate {
 
    weak var delegate: MapViewObserver?
    
    private var webSrvcHandler: WebServiceHandler?
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var currLocationButton: NSButton!
    
    private var latitude: Double = 0.0
    
    private var longitude: Double = 0.0
    
    private let defaults = UserDefaults.standard
    
    private var timer: Timer?

    private var baseUrl: String? {
        
        return Utility.readValue(fromplistFile: Constants.Plist.configPlist, forKey: Constants.Plist.baseURL)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapClicked))
        mapView.addGestureRecognizer(recognizer)
        getCurrentLocationInfo()
    }

    
    override func viewDidAppear() {
        
        showLastAnnotatedLocationOnMap()
    }
    

    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        captureUserLocation()
        Logger.debugLog("viewWillDisappear")
    }
    

    func startLoadingData(withTimeInterval value: Int) {
        
        startTimerForDataLoad(timeInterval: Double(value))
    }

    
    private func prepareWebServiceHandler() {
        
        self.webSrvcHandler =  WebServiceHandler(with:baseUrl, latitude: latitude, longitude: longitude, parserDelegate: self)
        self.webSrvcHandler?.delegate = self
    }


    private func getCurrentLocationInfo() {
        
        let locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 10.0
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
    }
    
    
    private func showLastAnnotatedLocationOnMap() {
        let lat = defaults.double(forKey: Constants.Location.latitude)
        let long = defaults.double(forKey: Constants.Location.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        mapView.setCenter(coordinate, animated: true)
    }
    
    private func startTimerForDataLoad(timeInterval: TimeInterval) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc private func loadData() {
        
        loadCoordinatesFromDefaults()
        prepareWebServiceHandler()
        loadDataFromRemoteServer()
    }
    
    
    private func loadCoordinatesFromDefaults() {
        
        latitude = defaults.double(forKey: Constants.Location.latitude)
        longitude = defaults.double(forKey: Constants.Location.longitude)
    }
    
    private func updateDefaults(_ annotation: MKAnnotation) {
        
        defaults.set(annotation.coordinate.latitude, forKey: Constants.Location.latitude)
        defaults.set(annotation.coordinate.longitude, forKey: Constants.Location.longitude)
    }
    
    private func captureUserLocation() {
        
        if (mapView.annotations.count > 0) {
            
            let annotation = mapView.annotations[0]
            updateDefaults(annotation)
            Logger.debugLog("captured user location latitude \(annotation.coordinate.latitude)")
            Logger.debugLog("captured user location longitude \(annotation.coordinate.longitude)")
        }
    }
    
    private func populateLastKnownCoordinates(lat: Double, long: Double) {
        
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
    
    
    private func loadDataFromRemoteServer() {

        self.webSrvcHandler?.fetchData()
    }
    
    @IBAction func doneButtonAction(_ sender: Any){
        
        if let mapVCdelegate = delegate {
            
            captureUserLocation()
            mapVCdelegate.doneButtonClicked()
            reloadData()
        }
        Logger.debugLog("Done button clicked")
    }
    
    
    //MARK:PareserDataUpdateDelegate
    
    func newDataDidBecomeAvaialble(model: WeatherData) {
        
        Logger.debugLog("newDataDidBecomeAvaialble")
        AgentUICoordinator.shared.refreshMenuItems(model: model)
    }

    
    //MARK:WebServiceProtocol
    
    func startAnimation() {
        
        AgentUICoordinator.shared.startTextAnimator()
    }
    
    func stopAnimation() {
        
        AgentUICoordinator.shared.stopTextAnimator()
    }
    
    //MARK:AgentUICoordinatorProtocol
    
    func reloadData() {
        
        let interval = Utility.refreshInterval(plistname: Constants.Plist.configPlist, and: Constants.Plist.keyDataRefreshFrequency)
        self.startLoadingData(withTimeInterval: interval)
    }
    
    //MARK:CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        defaults.set(locValue.latitude, forKey: Constants.Location.latitude)
        defaults.set(locValue.longitude, forKey: Constants.Location.longitude)
        Logger.debugLog("Current location = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        Logger.debugLog("locationManager didFailWithError \(error)")
    }
    
}


