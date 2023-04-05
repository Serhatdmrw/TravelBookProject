//
//  HomeViewModel.swift
//  TravelBookProject
//
//  Created by Serhat Demir on 5.04.2023.
//

import Foundation
import UIKit
import CoreData

protocol HomeViewModelDelegate:AnyObject {
    func didGetDataSuccess(titleArray: [String], idArray: [UUID])
    func didGetDataFaile(messega: String)
    func didCommitDataFail(messega : String)
}

class HomeViewModel {
    
    // MARK: - Delegate
    weak var delegate : HomeViewModelDelegate?
    
    // MARK: - Properties
    var titleArray = [String]()
    var idArray = [UUID]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()

    func getData() {
        titleArray.removeAll()
        idArray.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
            for result in results as! [NSManagedObject] {
                if let title = result.value(forKey: "title") as? String {
                    titleArray.append(title)
                    if let id = result.value(forKey: "id") as? UUID {
                        idArray.append(id)
                        if let latitude = result.value(forKey: "latitude") as? Double {
                            latitudeArray.append(latitude)
                            if let longtitude = result.value(forKey: "longitude") as? Double {
                                longitudeArray.append(longtitude)
                                delegate?.didGetDataSuccess(titleArray: titleArray, idArray: idArray)
                            }
                        }
                    }
                }
            }
        }
            
    } catch {
            delegate?.didGetDataFaile(messega: error.localizedDescription)
        }
    }
    
    func commitData(idS : UUID) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = true
        let idString = idS.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let id = result.value(forKey: "id") as? UUID {
                    if id == idS {
                        context.delete(result)
                        do {
                            try context.save()
                        } catch {
                            print("error")
                    }
                }
            }
        }
    } catch {
            delegate?.didCommitDataFail(messega: error.localizedDescription)
    }
    }
}
