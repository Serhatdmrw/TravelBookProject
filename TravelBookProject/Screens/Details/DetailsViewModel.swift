//
//  DetailsViewModel.swift
//  TravelBookProject
//
//  Created by Serhat Demir on 5.04.2023.
//

import Foundation
import UIKit
import CoreData
import MapKit
import CoreLocation

protocol DetailsViewModelDelegate:AnyObject {
    func didSaveDataFail(messega: String)
    func didFilteringData(messega: String)
}

class DetailsViewModel {
    
    // MARK: - Delegate
    weak var delegate : DetailsViewModelDelegate?
    
    func saveData(title: String, subTitle: String, latitude: Double, longtitude: Double) {
     
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let Places = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        Places.setValue(title, forKey: "title")
        Places.setValue(subTitle, forKey: "subtitle")
        Places.setValue(latitude, forKey: "latitude")
        Places.setValue(longtitude, forKey: "longitude")
        Places.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
        } catch {
            delegate?.didSaveDataFail(messega: error.localizedDescription)
        }
    }
    
    func filteringData(id: UUID, selectedTitle : inout String, selectedSubTitle: inout String, selectedLatitude: inout Double, selectedLongtitude: inout Double, mapView: MKMapView, locationManager: CLLocationManager) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        let idString = id.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        
        do {
        let results = try context.fetch(fetchRequest)
        if results.count > 0 {
            for result in results as! [NSManagedObject] {
                if let title = result.value(forKey: "title") as? String {
                    selectedTitle = title
                    if let subTitle = result.value(forKey: "subtitle") as? String {
                        selectedSubTitle = subTitle
                        if let latitude = result.value(forKey: "latitude") as? Double {
                            selectedLatitude = latitude
                            if let longtitude = result.value(forKey: "longitude") as? Double {
                                selectedLongtitude = longtitude
                                
                                let annotation = MKPointAnnotation()
                                annotation.title = selectedTitle
                                annotation.subtitle = selectedSubTitle
                                annotation.coordinate = CLLocationCoordinate2D(latitude: selectedLatitude, longitude: selectedLongtitude)
                                mapView.addAnnotation(annotation)
                                
                                let coordinate = CLLocationCoordinate2D(latitude: selectedLatitude, longitude: selectedLongtitude)
                                locationManager.stopUpdatingLocation()
                                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                let region = MKCoordinateRegion(center: coordinate, span: span)
                                mapView.setRegion(region, animated: true)
                            }
                        }
                    }
                }
            }
        }
    } catch {
            delegate?.didSaveDataFail(messega: error.localizedDescription)
        }
    }
}
