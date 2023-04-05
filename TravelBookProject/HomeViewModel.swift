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
}

class HomeViewModel {
    
    weak var delegate : HomeViewModelDelegate?
    var titleArray = [String]()
    var idArray = [UUID]()
    
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
                        delegate?.didGetDataSuccess(titleArray: titleArray, idArray: idArray)
                    }
                }
            }
        }
            
    } catch {
            delegate?.didGetDataFaile(messega: error.localizedDescription)
            
        }
    }
}
