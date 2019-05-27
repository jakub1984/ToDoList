//
//  Helper.swift
//  ToDoList
//
//  Created by Jakub Perich on 24/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Helper {
    static var app: Helper = {
        return Helper()
    }()
    
    var categories = [Categories]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    func showAlert(title: String, message:String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message,    preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    func loadCategories(){
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
//        tableView.reloadData()
    }

}
