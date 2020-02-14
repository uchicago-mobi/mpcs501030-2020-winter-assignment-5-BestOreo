//
//  ViewController.swift
//  assignment_5
//
//  Created by 葛帅琦 on 2/9/20.
//  Copyright © 2020 Shuaiqi Ge. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var board: UIView!
    @IBOutlet weak var boardTitle: UILabel!
    @IBOutlet weak var boardDescription: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    var annotationPlaces: [Place] = Array()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        board.isHidden = true
        boardDescription.numberOfLines = 0
        
        // reference: https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // Assing self delegate on userNotificationCenter
        self.userNotificationCenter.delegate = self
        
        // Notification center property
        self.requestNotificationAuthorization()
    }
    
    // Local Notification Reference: https://programmingwithswift.com/how-to-send-local-notification-with-swift-5/
    let userNotificationCenter = UNUserNotificationCenter.current()

    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }

    func registerNotification(name: String) {
        print("registerNotification", name)
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Welcome to " + name
        notificationContent.body = DataManager.sharedInstance.getDescription(name: name)
        
        if let url = Bundle.main.url(forResource: "dune", withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "dune", url: url, options: nil) {
                notificationContent.attachments = [attachment]
            }
        }
    
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: name, content: notificationContent, trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var position = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let placeDescrption = DataManager.sharedInstance.placesDescription
        for locationName in placeDescrption.keys{
            let newPlace = Place()
            newPlace.name = locationName
            newPlace.longDescription = placeDescrption[locationName]!
            annotationPlaces.append(newPlace)
            position = DataManager.sharedInstance.getLocation(name: locationName)
            let annotation = newAnnotation(location: position, title: newPlace.name!, subtitle: newPlace.longDescription!)
            mapView.addAnnotation(annotation)
        }
        self.mapViewMoveTo(location: position)
    }
    
    
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
    
    func newAnnotation(location: CLLocationCoordinate2D, title: String, subtitle: String) -> MKPointAnnotation{
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = title
        annotation.subtitle = subtitle
        return annotation
    }
    
    func mapViewMoveTo(location: CLLocationCoordinate2D) {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        for name in DataManager.sharedInstance.favoritesList {
            let location = DataManager.sharedInstance.getLocation(name: name)
            let distance = MKMapPoint(locValue).distance(to: MKMapPoint(location))
            // Because it's hard to use location trigger here. Because location trigger only works at region edge
            if distance < 2000 { // send notifcation when less than 2km
                registerNotification(name: name)
            }
        }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
}


extension MapViewController: PlacesFavoritesDelegate {
  
    func favoritePlace(name: String) {
        let position = DataManager.sharedInstance.getLocation(name: name)
        mapViewMoveTo(location: position)
        for annotation in mapView.annotations {
            if annotation.title == name {
                self.mapView.selectAnnotation(annotation, animated: true)
                break
            }
        }
    }
    
}

