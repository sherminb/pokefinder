//
//  ViewController.swift
//  pokefinder
//
//  Created by Kuala on 2017-04-14.
//  Copyright © 2017 Litroom. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase


class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var mapCeneterd = false//center the map on load
    
    var geoFire: GeoFire!
    var geoFireRef : FIRDatabaseReference!//reference to the firebase db that geofire uses for saving pokemon locations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        
        
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
    }
    func createSighting(forLocation location:CLLocation, withPokemon pokeId: Int){
        geoFire.setLocation(location, forKey: "\(pokeId)")
    }
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    func locationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            mapView.showsUserLocation = true
        }else{
            
        }
    }
    func centerMap(location: CLLocation){
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let location = userLocation.location{
            if !mapCeneterd{
                centerMap(location: location)
                mapCeneterd = true
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var newAnnotation : MKAnnotationView?
        if annotation.isKind(of: MKUserLocation.self){
            newAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            newAnnotation?.image =  UIImage(named: "ash")
        }
        return newAnnotation
        
        
    }
    func showOnMap(location: CLLocation){
        
        let q = geoFire!.query(at: location, withRadius: 2.5)//look for pokemons around
        let _ = q!.observe(.keyEntered, with: {(key,location) in
            if let key = key, let location = location{
                let anno = PokeAnnotation(coordinate: location.coordinate, pokeId: Int(key)!)
                self.mapView.addAnnotation(anno)
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func spotPokeman(_ sender: Any) {
      //put a pokemon at the center of the map
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        //randomly select a pokemon
        let rand = arc4random_uniform(151)+1 //we have 151 pokemons
        createSighting(forLocation: loc, withPokemon: Int(rand))//add the pokemon to geofire
        
    }

}

