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
    
    let locationHelper = LocationManagerHelper()
    
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
    
    
    lazy private var isCurrentLocationAvailable: Bool = {
        
        return locationHelper.isUserCurrentLocationAvailable
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
    }

    
    override func viewDidAppear() {
        
        showLastAnnotatedLocation()
        
    }
    

    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        captureUserSelectedLocation()
        Logger.debugLog("viewWillDisappear")
    }
    

    //MARK: Helpers
    
    
//    private func prepareAndShowMap() {
//        
//        if isCurrentLocationAvailable {
//            
//            let coordinate = CLLocationCoordinate2D(latitude: locationHelper.userCurrentCoordinates.latitude, longitude: locationHelper.userCurrentCoordinates.longitude)
//            mapView.setCenter(coordinate, animated: true)
//        } else {
//            
//            showLastAnnotatedLocation()
//        }
//    }

    
    
    func startLoadingData(withTimeInterval value: Int) {
        
        startTimerForDataLoad(timeInterval: Double(value))
    }

    
    private func prepareWebServiceHandler() {
        
        webSrvcHandler =  WebServiceHandler(with:baseUrl, latitude: userDefaultsCoordinates.latitude, longitude: userDefaultsCoordinates.longitude, parserDelegate: self)
        webSrvcHandler?.delegate = self
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
    
    private func captureUserSelectedLocation() {
        
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
        
        captureUserSelectedLocation()
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
        
        stopAnimation()
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
    
    
}


