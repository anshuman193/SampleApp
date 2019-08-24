//
//  ViewController.swift
//  SampleApp
//
//  Created by Anshuman Singh on 8/23/19.
//  Copyright © 2019 Anshuman Singh. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var currLocationButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    private func setup(){
        
    }
    
    @IBAction func currLocationButtonAction(_ sender: Any){
        print("current location button clicked")
        
    }

}

