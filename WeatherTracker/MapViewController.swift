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

class MapViewController: NSViewController {
    
    let locationHelper = LocationManagerHelper()
    
    private let popOverView = NSPopover()
    
    private var webSrvcHandler: WebServiceHandler?
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var doneButton: NSButton!
    
    @IBOutlet var currentLocationButton: NSButton!

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
        
        locationHelper.delegate = self
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
    
    private func updateDefaults(_ location: CLLocation) {
        
        defaults.set(location.coordinate.latitude, forKey: Constants.Location.latitude)
        defaults.set(location.coordinate.longitude, forKey: Constants.Location.longitude)
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
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        captureUserSelectedLocation()
        closePopOver()
        refreshData()
        Logger.debugLog("Done button clicked")
    }

    @IBAction func currentLocationButtonAction(_ sender: Any) {
        
        locationHelper.useCurrentLocationToFetchData()
        closePopOver()
        Logger.debugLog("Current Location button clicked")
    }

    
    //MARK: Handle Popover
    
    func closePopOver() {

        popOverView.close()
    }
}

extension MapViewController: AgentUICoordinatorProtocol {
    
    //MARK:AgentUICoordinatorProtocol
    
    func refreshData() {
        
        let interval = Utility.refreshInterval(plistname: Constants.Plist.configPlist, and: Constants.Plist.keyDataRefreshFrequency)
        startLoadingData(withTimeInterval: interval)
    }
    
    func refreshData(with location: CLLocation) {
        
        updateDefaults(location)
        refreshData()
    }
    
    func showMapInPopOver() {
        
        guard let uiElement = uiCoordinator?.statusItem else {
            return
        }

        popOverView.contentViewController = self
        popOverView.behavior = .transient
        popOverView.show(relativeTo: uiElement.button!.bounds, of: uiElement.button!, preferredEdge: .maxY)
    }
}

extension MapViewController: PareserDataUpdateProtocol {
    
    //MARK:PareserDataUpdateDelegate
    
    func didParseData(model: WeatherData?) {
        
        guard let data = model else {
            
            Logger.debugLog("No new data")
            return
        }
        
        Logger.debugLog("new data became avaialble")
        uiCoordinator?.refreshMenuItems(model: data)
    }

}

extension MapViewController: WebServiceProtocol {
    
    //MARK:WebServiceProtocol
    
    func startAnimation() {
        
        stopAnimation()
        uiCoordinator?.startTextAnimator()
    }
    
    func stopAnimation() {
        
        uiCoordinator?.stopTextAnimator()
    }
}


extension MapViewController: LocationManagerHelperProtocol {
    
    func currentLocationAvailablityDidFail() {
        
        refreshData()
    }
    
    func currentLocationAvailablityDidSucceed(locations: [CLLocation]) {
        
        let currLocation = getMostRecentLocation(locationArray: locations)
        updateData(with: currLocation)
    }
    
    private func getMostRecentLocation(locationArray: [CLLocation]) -> CLLocation {
        
        let lastItemIndex = locationArray.count - 1
        return locationArray[lastItemIndex]
    }
    
    private func updateData(with currentloc: CLLocation) {
        
       self.refreshData(with: currentloc)
    }
}
