//
//  NewTaskViewController.swift
//  ToDoList
//
//  Created by Jakub Perich on 22/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var txtDatePicker: UITextField!
    let datePicker = UIDatePicker()

    
    var selectedTask: Tasks?{
        didSet{
//            loadItems()
            print("Title \(String(describing: self.selectedTask?.title))")
            print("Category: \(String(describing: self.selectedTask?.category))")

        }
    }
    
    let categoryData = [
        [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)],
        ["Swift","Project","Priority","Homework","Non-work"]
    ]
    var managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var blue = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        showDatePicker()
        // Do any additional setup after loading the view.
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        
        //Date picker ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        txtDatePicker.inputAccessoryView = toolbar
        txtDatePicker.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        txtDatePicker.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        selectedTask?.dueDate = datePicker.date

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
