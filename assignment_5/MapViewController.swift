//
//  ViewController.swift
//  assignment_5
//
//  Created by 葛帅琦 on 2/9/20.
//  Copyright © 2020 Shuaiqi Ge. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var board: UIView!
    
    @IBOutlet weak var boardTitle: UILabel!
    @IBOutlet weak var boardDescription: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    var annotationPlaces: [Place] = Array()
    
    @IBAction func likeBtn(_ sender: UIButton) {
        if sender.isSelected == false {
            sender.isSelected = true
            DataManager.sharedInstance.saveFavorites(name: boardTitle.text!)
        }else{
            sender.isSelected = false
            DataManager.sharedInstance.deleteFavorite(name: boardTitle.text!)
        }
    }
    
    @IBAction func favoriteBtnTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FavoritesViewController") as! FavoritesViewController
        vc.delegate = self
        show(vc, sender: self)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return PlaceMarkerView()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        board.isHidden = false
        boardTitle.text = view.annotation!.title as? String
        boardTitle.font = UIFont(name: boardTitle.font.fontName, size: 30)
        if boardTitle.text!.count >= 20{
            boardTitle.font = UIFont(name: boardTitle.font.fontName, size: 24)
        }
        
        boardDescription.text = view.annotation!.subtitle as? String
        boardDescription.sizeToFit()
        likeBtn.isSelected = DataManager.sharedInstance.isFavorites(name: boardTitle.text!)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        board.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        board.isHidden = true
        boardDescription.numberOfLines = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        let locationInfo = DataManager.sharedInstance.placesDict
        for (index, location) in locationInfo.enumerated() {
            let newPlace = Place()
            newPlace.name = location["name"] as? String
            newPlace.longDescription = location["description"] as? String
            annotationPlaces.append(newPlace)
            let long: Double = location["long"] as! Double
            let lat: Double = location["lat"] as! Double
            let annotation = newAnnotation(lat: lat, long: long, title:  newPlace.name!, subtitle: newPlace.longDescription!)
            mapView.addAnnotation(annotation)
            if index == 0 {
                self.mapViewMoveTo(lat: lat, long: long)
            }
        }
    }
    
    func newAnnotation(lat: Double, long: Double, title: String, subtitle: String) -> MKPointAnnotation{
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = title
        annotation.subtitle = subtitle
        return annotation
    }
    
    func mapViewMoveTo(lat: Double, long: Double) {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.setRegion(region, animated: true)
    }
    
    func getPlist(withName name: String) -> NSArray{
        let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: name, ofType: "plist")!);
        return dictionary?["places"] as! NSArray
    }
}

extension MapViewController: PlacesFavoritesDelegate {
  
    func favoritePlace(name: String) {
        let postion = DataManager.sharedInstance.getLocation(name: name)
        mapViewMoveTo(lat: postion["lat"]!, long: postion["long"]!)
        for annotation in mapView.annotations {
            if annotation.title == name {
                self.mapView.selectAnnotation(annotation, animated: true)
                break
            }
        }
    }
}

