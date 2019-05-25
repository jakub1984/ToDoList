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
    
    //    let primaryColor = UIColor.blue.alpha(0.3)
    //    let secondaryColor = UIColor.white.alpha(0.7)
    //    let defaultStateColor = UIColor.white.alpha(0.5)
    //    let placeHolderColor = UIColor.white.alpha(0.4)
    
    let titleTextAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 26)!]
    
    func showAlert(title: String, message:String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message,    preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        vc.present(alert, animated: true, completion: nil)
    }
}
