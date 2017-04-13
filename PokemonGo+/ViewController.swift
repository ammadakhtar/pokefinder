//
//  ViewController.swift
//  PokemonGo+
//
//  Created by Ammad on 12/04/2017.
//  Copyright © 2017 Ammad. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    let locationmanager = CLLocationManager()
    var maphascenterd = false
    var geofire : GeoFire!
    var geofireRef : FIRDatabaseReference!                  // creating a geofire reference of firebase dtabase reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        map.userTrackingMode = MKUserTrackingMode.follow     //follows user location while user is moving
        geofireRef = FIRDatabase.database().reference()
        geofire = GeoFire(firebaseRef: geofireRef)           //initialize Gerofire
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {                                             //func to get user location permission and everytime view loads it will check for it
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {// if locatoin sharing is authorized than user location would be shown on map
            map.showsUserLocation =  true
        } else {
            locationmanager.requestWhenInUseAuthorization()                 //if location is not authorized this would be called
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) { //when auth status changes we need to update map with user location, once status changes this function would be called
        if status == .authorizedWhenInUse {
            map.showsUserLocation = true
        }
    }
    
    func centreMapOnLocation ( location : CLLocation) { //func to centre map to user location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        map.setRegion(coordinateRegion, animated: true)
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) { //whenever device's gps coordinate are updated update map
        if let loc = userLocation.location {
            if !maphascenterd {             // do it only the first time when map is loaded
                centreMapOnLocation(location: loc)
                maphascenterd = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { // change user location annotation to custom image
        let annoidentifier = "Pokemon"
        var annotationview : MKAnnotationView?
        if annotation.isKind(of: MKUserLocation.self) {
            annotationview = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationview?.image = UIImage(named: "ash")
        } else if let deqAnno = map.dequeueReusableAnnotationView(withIdentifier: annoidentifier) { //annotation for pokemon
            annotationview = deqAnno
            annotationview?.annotation = annotation
        } else { // to create an annotation if no annotation is present
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoidentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationview = av
        }
        
        if let annotationview = annotationview , let anno = annotation as? PokeAnnotation {// whatever annotation is customise it if its user annotatoin this wont run
            annotationview.canShowCallout = true // its necessary to set title as we did in PokeAnnotation file otherwise app would crash . title setting is necessary whenevr u show an annotation.canshowcallout
            annotationview.image = UIImage(named: "\(anno.pokemonNumber)")
            let Btn = UIButton()
            Btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            Btn.setImage(UIImage(named: "location-map-flat"), for: .normal)
            annotationview.rightCalloutAccessoryView = Btn
        }
        return annotationview
    }
    
    func createSighting(forlocation location: CLLocation , withPokemon pokeId : Int) {   //func used to store a pokemon on map with a location on map of that pokemon
        geofire.setLocation(location, forKey: "\(pokeId)")
        
    }
    
    func showSightingOnMap(location : CLLocation) {        //show pokemon on map which are saved on map
        let circleQuery = geofire!.query(at: location, withRadius: 2.5)
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let key = key , let location = location {
                let anno = PokeAnnotation(coordinate: location.coordinate, pokemonNumber: Int(key)!)
                self.map.addAnnotation(anno)
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) { // whenevr the user wanders around the map the pokemon on map should appear
        let loc = CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude)
       showSightingOnMap(location: loc)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let anno = view.annotation as? PokeAnnotation {
            let place = MKPlacemark(coordinate: anno.coordinate)
            let destination = MKMapItem(placemark: place)
            destination.name = "Pokemon Sighting"
            let regionDistance : CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            let options = [MKLaunchOptionsMapCenterKey: NSValue (mkCoordinate : regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan:regionSpan.span),MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    @IBAction func randomPokemonBtn(_ sender: UIButton) {
    // put random pokemon at centre of map when pokeball is pressed
//        let loc = CLLocation(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude)
//        let rand = arc4random_uniform(151)+1
//        createSighting(forlocation: loc, withPokemon: Int(rand))
         
    
    }
    
}

