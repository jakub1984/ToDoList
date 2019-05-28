//
//  SettingsViewController.swift
//  ToDoList
//
//  Created by Jakub Perich on 22/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import CoreData

class NewCategoryViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let colorArray : [Double] = [ 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199 ]
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var nameLbl: UITextField!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLbl.delegate = self
        nameLbl.becomeFirstResponder()
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        saveNewCategory()
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        selectedColorView.backgroundColor = UIColor(hex: colorArray[Int(slider.value)])
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
            showAlertAndDismiss(title: "Success", message: "New category was created", vc: self)
        }catch {
            print("Error saving item with \(error)")
        }
    }
    
    func showAlertAndDismiss(title: String, message:String, vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(okAction)
            vc.present(alert, animated: true, completion: nil)
        }
    }
    
    //    Dismiss keyboard after pressing Enter button
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Recognizes enter key in keyboard
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameLbl.resignFirstResponder()
        return true
    }
    
}
