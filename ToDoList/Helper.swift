//
//  Helper.swift
//  ToDoList
//
//  Created by Jakub Perich on 24/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    static var app: Helper = {
        return Helper()
    }()
    
    let defaultCategories : [String] = ["Swift","Project","Priority","Homework","Non-work"]
    let defaultColors : [Double] = [0x79A700, 0xF68B2C, 0xF5522D, 0xE2B400, 0xFF6E83]


    func showAlert(title: String, message:String, vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            vc.present(alert, animated: true, completion: nil)
        }
    }

}
