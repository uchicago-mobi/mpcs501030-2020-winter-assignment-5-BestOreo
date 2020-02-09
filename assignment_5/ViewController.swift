//
//  ViewController.swift
//  assignment_5
//
//  Created by 葛帅琦 on 2/9/20.
//  Copyright © 2020 Shuaiqi Ge. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let location = CLLocationCoordinate2D(latitude: 41.8728043, longitude: -87.6334798)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "City of Chicago"
        annotation.subtitle = "Chicago"
        mapView.addAnnotation(annotation)
    }

}

