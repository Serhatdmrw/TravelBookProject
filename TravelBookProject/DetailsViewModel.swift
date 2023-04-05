//
//  DetailsViewModel.swift
//  TravelBookProject
//
//  Created by Serhat Demir on 5.04.2023.
//

import Foundation
import UIKit
import CoreData

protocol DetailsViewModelDelegate:AnyObject {
    func didSaveDataFail(messega: String)
}

class DetailsViewModel {
    
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
}
