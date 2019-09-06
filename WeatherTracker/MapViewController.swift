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

class MapViewController: NSViewController, PareserDataUpdateDelegate, WebServiceProtocol, AgentUICoordinatorProtocol, CLLocationManagerDelegate {
    
    private let popOverView = NSPopover()
    
    private var webSrvcHandler: WebServiceHandler?
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var currLocationButton: NSButton!
        
    private let defaults = UserDefaults.standard
    
    private var timer: Timer?

    private var baseUrl: String? {
        
        return Utility.readValue(fromplistFile: Constants.Plist.configPlist, forKey: Constants.Plist.baseURL)
    }
    
    private var userDefaultsCoordinates: (latitude: Double, longitude: Double) {
    
        let latitude = defaults.double(forKey: Constants.Location.latitude)
        let longitude = defaults.double(forKey: Constants.Location.longitude)
        return (latitude, longitude)
    }
    
    
    private var uiCoordinator: AgentUICoordinator? = {
        
        let uiCoordinator = AgentUICoordinator()
        return uiCoordinator
    }()
    
    
    
    func setup() {
        
        guard let uiCoordinator = uiCoordinator else {
            
            Logger.debugLog("Failed to Initialize MapViewController")
            return
        }
        
        uiCoordinator.delegate = self
        uiCoordinator.setup(withTitle: Constants.agentDefaultName)
        
    }
    
    //MARK: View Controller Lifecyle
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapClicked))
        mapView.addGestureRecognizer(recognizer)
        getCurrentLocationInfo()
    }

    
    override func viewDidAppear() {
        
        showLastAnnotatedLocation()
    }
    

    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        captureUserLocation()
        Logger.debugLog("viewWillDisappear")
    }
    

    //MARK: Helpers
    
    func startLoadingData(withTimeInterval value: Int) {
        
        startTimerForDataLoad(timeInterval: Double(value))
    }

    
    private func prepareWebServiceHandler() {
        
        webSrvcHandler =  WebServiceHandler(with:baseUrl, latitude: userDefaultsCoordinates.latitude, longitude: userDefaultsCoordinates.longitude, parserDelegate: self)
        webSrvcHandler?.delegate = self
    }


    private func getCurrentLocationInfo() {
        
        let locationManager = CLLocationManager()
        
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways:
                Logger.debugLog("authorizedAlways")
                break

        case .denied:
            Logger.debugLog("denied")
            break

        case .notDetermined:
            Logger.debugLog("notDetermined")
            break
            
        case .restricted:
            Logger.debugLog("restricted")
            break
            
            default:
                Logger.debugLog("default")
            
        }
        
        
        
        if CLLocationManager.locationServicesEnabled() {
        

            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 10.0
            locationManager.requestLocation()
            
            locationManager.startUpdatingLocation()
        }
    }
    
    
    private func showLastAnnotatedLocation() {
        
        let coordinate = CLLocationCoordinate2D(latitude: userDefaultsCoordinates.latitude, longitude: userDefaultsCoordinates.longitude)
        mapView.setCenter(coordinate, animated: true)
    }
    
    private func startTimerForDataLoad(timeInterval: TimeInterval) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc private func loadData() {
        
        prepareWebServiceHandler()
        loadDataFromRemoteServer()
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

        webSrvcHandler?.fetchData()
    }
    
    @IBAction func doneButtonAction(_ sender: Any){
        
        captureUserLocation()
        closePopOver()
        reloadData()
        Logger.debugLog("Done button clicked")
    }
    
    
    //MARK:PareserDataUpdateDelegate
    
    func didParseData(model: WeatherData?) {
        
        guard let data = model else {
            
            Logger.debugLog("No new data")
            return
        }
        
        Logger.debugLog("new data became avaialble")
        uiCoordinator?.refreshMenuItems(model: data)
    }

    
    //MARK:WebServiceProtocol
    
    func startAnimation() {
        
        uiCoordinator?.startTextAnimator()
    }
    
    func stopAnimation() {
        
        uiCoordinator?.stopTextAnimator()
    }
    
    //MARK: Handle Popover
    
    func closePopOver() {
        
        
        popOverView.close()
    }
    
    func showMapInPopOver() {
        
        guard let uiElement = uiCoordinator?.statusItem else {
            return
        }
        
        popOverView.contentViewController = self
        popOverView.behavior = .transient
        popOverView.show(relativeTo: uiElement.button!.bounds, of: uiElement.button!, preferredEdge: .maxY)
    }
    
    //MARK:AgentUICoordinatorProtocol
    
    func reloadData() {
        
        let interval = Utility.refreshInterval(plistname: Constants.Plist.configPlist, and: Constants.Plist.keyDataRefreshFrequency)
        startLoadingData(withTimeInterval: interval)
    }
    
    //MARK:CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        Logger.debugLog("didDetermineState");
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        Logger.debugLog("didStartMonitoringFor");
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateTo newLocation: CLLocation, from oldLocation: CLLocation) {
        
        Logger.debugLog("didUpdateTo newLocation");
    }
    
   
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


