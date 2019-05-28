//
//  SettingsViewController.swift
//  ToDoList
//
//  Created by Jakub Perich on 22/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import CoreData

class NewCategoryViewController: UIViewController {
   
    let colorArray : [Double] = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var nameLbl: UITextField!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLbl.becomeFirstResponder()
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        saveNewCategory()
        showAlertAndDismiss(title: "Success", message: "New category was created", vc: self)

    }
    

    
    @IBAction func sliderChanged(_ sender: UISlider) {
        selectedColorView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(slider.value)])
    }
    
    func uiColorFromHex(rgbValue: Double) -> UIColor {
        
        let red =   CGFloat((Int(rgbValue) & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((Int(rgbValue) & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(Int(rgbValue) & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func saveNewCategory() {
        guard let name = nameLbl.text, !name.isEmpty else {
            Helper.app.showAlert(title: "Mandatory fields missing:", message: "Please select name", vc: self)
            nameLbl.becomeFirstResponder()
            return
        }
        
        let newCategory = Categories(context: context)
        newCategory.categoryColor = colorArray[Int(slider.value)]
        newCategory.categoryName = name.capitalized

        do{
            try context.save()
            print("new category: \(newCategory)")
        }catch {
            print("Error saving item with \(error)")
        }
    }
    
    func showAlertAndDismiss(title: String, message:String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(okAction)
        vc.present(alert, animated: true, completion: nil)
    }

}
