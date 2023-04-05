//
//  DetailsViewController.swift
//  TravelBookProject
//
//  Created by Serhat Demir on 5.04.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class DetailsViewController: UIViewController {
    
    // MARK: - Outles
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commenText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongtitude = Double()
    private let viewModel = DetailsViewModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addDelegates()
        userLocation()
        addLongGestureRecognizer()
    }
    
    // MARK: - Actions
    @IBAction func saveButton(_ sender: Any) {
        if nameText.text != "" && commenText.text != "" {
            viewModel.saveData(title: nameText.text!, subTitle: commenText.text!, latitude: chosenLatitude, longtitude: chosenLongtitude)
            NotificationCenter.default.post(name: NSNotification.Name("newPlaces"), object: nil)
            navigationController?.popViewController(animated: true)
        } else {
            self.makeAlert(tittleInput: "Error", messegaInput: "Name/Commen")
        }
    }
}

// MARK: - Helpers
private extension DetailsViewController {
    
    func addLongGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let tounchPoint = gestureRecognizer.location(in: mapView)
            let tounchCoordinate = mapView.convert(tounchPoint, toCoordinateFrom: mapView)
            
            self.chosenLatitude = tounchCoordinate.latitude
            self.chosenLongtitude = tounchCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = tounchCoordinate
            annotation.title = nameText.text
            annotation.subtitle = commenText.text
            mapView.addAnnotation(annotation)
        }
    }
    
    func makeAlert(tittleInput: String, messegaInput: String) {
        let alert = UIAlertController(title: tittleInput, message: messegaInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate, CLLocationManagerDelegate
extension DetailsViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func addDelegates() {
        mapView.delegate = self
        locationManager.delegate = self
        viewModel.delegate = self
    }
    
    func userLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }
}

extension DetailsViewController: DetailsViewModelDelegate {
    func didSaveDataFail(messega: String) {
        self.makeAlert(tittleInput: "Error", messegaInput: messega)
    }
}
