//
//  ViewController.swift
//  SampleApp
//
//  Created by Anshuman Singh on 8/23/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Cocoa
import MapKit
import SwiftyJSON


class ViewController: NSViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var currLocationButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
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

    
    private func setup(){
        
    }
    
    private func captureUserLocation(){
        
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
    
    @IBAction func currLocationButtonAction(_ sender: Any){
        
        Logger.debugLog("current location button clicked")
    }

}

