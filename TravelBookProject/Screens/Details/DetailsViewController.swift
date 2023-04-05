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
    @IBOutlet private weak var nameText: UITextField!
    @IBOutlet private weak var commenText: UITextField!
    @IBOutlet private weak var mapView: MKMapView!
    
    // MARK: - Properties
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongtitude = Double()
    private let viewModel = DetailsViewModel()
    var chosenTitle = ""
    var chosenİd = UUID()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addDelegates()
        userLocation()
        addLongGestureRecognizer()
        ifChosenPlaces()
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
    
    func ifChosenPlaces() {
        if chosenTitle != "" {
            viewModel.filteringData(id: chosenİd, selectedTitle: &nameText.text!, selectedSubTitle: &commenText.text!, selectedLatitude: &chosenLatitude, selectedLongtitude: &chosenLongtitude, mapView: mapView, locationManager: locationManager)
        } else {
            nameText.text = ""
            commenText.text = ""
        }
    }
    
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let reusİd = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusİd)
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reusİd)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
    }
        return pinView
        }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let requestLocation = CLLocation(latitude: chosenLatitude, longitude: chosenLongtitude)
        CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
            if let placemark = placemarks {
                if placemark.count > 0 {
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = self.nameText.text
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
        }
    }
}
// MARK: - DetailsViewModelDelegate
extension DetailsViewController: DetailsViewModelDelegate {
    func didFilteringData(messega: String) {
        self.makeAlert(tittleInput: "Error", messegaInput: messega)
    }
    
    func didSaveDataFail(messega: String) {
        self.makeAlert(tittleInput: "Error", messegaInput: messega)
    }
}
