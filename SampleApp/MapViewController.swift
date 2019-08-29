//
//  MapViewController.swift
//  SampleApp
//
//  Created by Anshuman Singh on 8/23/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Cocoa
import MapKit


class MapViewController: GenericViewController<ViewControllerType.Type>, PareserDataUpdateDelegate, WebServiceProtocol, AgentUICoordinatorProtocol {
 
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var currLocationButton: NSButton!
    fileprivate var latitude: Double = 0.0
    fileprivate var longitude: Double = 0.0
    fileprivate let defaults = UserDefaults.standard
    fileprivate var timer: Timer?

    fileprivate var baseUrl: String? {
        
        return Utility.readValue(fromplistFile: Constants.Plist.kConfigPlist, forKey: Constants.Plist.kBaseURL)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
//        loadCoordinatesFromDefaults()
        populateLastKnownCoordinates(lat: latitude, long: longitude)
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapClicked))
        mapView.addGestureRecognizer(recognizer)
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

    func startLoadingData(withTimeInterval value: Int) {
        
        startTimerForDataLoad(timeInterval: Double(value))
    }
    
    
    private func startTimerForDataLoad(timeInterval: TimeInterval) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc private func loadData() {
        
        loadCoordinatesFromDefaults()
        loadDataFromRemoteServer()
    }
    
    
    fileprivate func loadCoordinatesFromDefaults() {
        
        latitude = defaults.double(forKey: Constants.Location.kLatitude)
        longitude = defaults.double(forKey: Constants.Location.kLongitude)
    }
    
    fileprivate func updateDefaults(_ annotation: MKAnnotation) {
        
        defaults.set(annotation.coordinate.latitude, forKey: Constants.Location.kLatitude)
        defaults.set(annotation.coordinate.longitude, forKey: Constants.Location.kLongitude)
    }
    
    fileprivate func captureUserLocation() {
        
        let annotation = mapView.annotations[0]
        updateDefaults(annotation)
        Logger.debugLog("captured user location latitude \(annotation.coordinate.latitude)")
        Logger.debugLog("captured user location longitude \(annotation.coordinate.longitude)")
    }
    
    fileprivate func populateLastKnownCoordinates(lat: Double, long: Double) {
        
        let anno = MKPointAnnotation()
        anno.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        mapView.addAnnotation(anno)
    }
    
    @objc fileprivate func mapClicked(recognizer: NSClickGestureRecognizer) {
        
        mapView.removeAnnotations(mapView.annotations)
        let location = recognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        pinAnnotation(at: coordinate)
    }
    
    fileprivate func pinAnnotation(at coordinate: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Your location"
        mapView.addAnnotation(annotation)
    }
    
    
    fileprivate func loadDataFromRemoteServer() {
        
        if let baseurl = baseUrl, let webServiceHandler = WebServiceHandler(with:baseurl, latitude: latitude, longitude: longitude, parserDelegate: self) {
            
            webServiceHandler.delegate = self
            webServiceHandler.fetchData()
        }
    }
    
    @IBAction func doneButtonAction(_ sender: Any){
        
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
        
        let interval = Utility.refreshInterval(plistname: Constants.Plist.kConfigPlist, and: Constants.Plist.kKeyDataRefreshFrequency)
        self.startLoadingData(withTimeInterval: interval)
    }
}


