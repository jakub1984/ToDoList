//
//  NewTaskViewController.swift
//  ToDoList
//
//  Created by Jakub Perich on 22/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var txtDatePicker: UITextField!
    @IBOutlet weak var pickerTextField: UITextField!
    let datePicker = UIDatePicker()
    let pickerView = UIPickerView()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryColor : Double!
    var categoryName : String!
    var dueDate : Date?
    var categories = [Categories]()
    var selectedTask: Tasks?

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        showCategoryPicker()
        showDatePicker()

        taskName.becomeFirstResponder()

        if let task = selectedTask {
            
            taskName.text = task.title
            if let date = task.dueDate {
                txtDatePicker.text = fullStringFromDate(date)
                datePicker.date = date
                dueDate = date
            }
            pickerTextField.text = task.category
            categoryName = task.category
            pickerTextField.backgroundColor = UIColor(hex: task.categoryColor)
            categoryColor = task.categoryColor
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        
        do {
            categories = try context.fetch(request)
            pickerView.reloadAllComponents()
        }catch{
            print("Error fetching data from context \(error)")
        }
        print("categories: \(categories)")
        
    }
    
    @IBAction func saveTaskTapped(_ sender: UIBarButtonItem) {
//    Making sure task name and category are set
        guard let title = taskName.text, !title.isEmpty else {
            Helper.app.showAlert(title: "Mandatory fields missing:", message: "Please select name", vc: self)
            taskName.becomeFirstResponder()
            return
        }
        
        guard let category = categoryName, !category.isEmpty else {
            Helper.app.showAlert(title: "Mandatory fields missing:", message: "Please select category", vc: self)
            pickerView.becomeFirstResponder()
            return
        }
        
        
        if let todo = self.selectedTask {
            todo.title = title
            todo.category = category
            todo.categoryColor = categoryColor
            todo.dueDate = dueDate
        } else {
            let newTodo = Tasks(context: context)
            newTodo.title = title
            newTodo.category = category
            newTodo.categoryColor = categoryColor
            newTodo.completed = false
            newTodo.dueDate = dueDate
            
        }
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)

        } catch {
            print("Error saving todo: \(error)")
        }
    }
    
    
//    Date picker
    func showDatePicker(){
        //Format Date
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 15
        datePicker.locale = Locale(identifier: "en_GB")
        
        //Date picker ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        txtDatePicker.inputAccessoryView = toolbar
        txtDatePicker.inputView = datePicker
    }
    
    @objc func doneDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        txtDatePicker.text = formatter.string(from: datePicker.clampedDate)
        dueDate = datePicker.clampedDate
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func dateFromString(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: date)
    }
    
    func fullStringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: date)
    }
    
    
//    Category picker
    func showCategoryPicker() {
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(cancelCategoryPicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([spaceButton,doneButton], animated: false)
        
        pickerTextField.inputAccessoryView = toolbar
        pickerTextField.inputView = pickerView
        
    }
    
    @objc func cancelCategoryPicker(){
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].categoryName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let category = categories[row].categoryName
        let color = categories[row].categoryColor
        pickerTextField.text = category
        pickerTextField.backgroundColor = UIColor(hex: color)
        categoryName = category
        categoryColor = color
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel?

        if view == nil {
            pickerLabel = UILabel()
//            Color the label's background
            let colors = categories[row].categoryColor
            pickerLabel!.backgroundColor = UIColor(hex: colors)
        }
        let titleData = categories[row].categoryName
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 18.0)!])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        return pickerLabel!
    }
    
    
    @IBAction func deleteTaskPressed(_ sender: UIButton) {
        if (selectedTask != nil) {
            context.delete(selectedTask!)
            
            do {
                try context.save()
                navigationController?.popViewController(animated: true)
                
            } catch {
                print("Error deleting items with \(error)")
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}


// Extending UIColor so it can read hex values
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Double) {
        self.init(
            red: (Int(hex) >> 16) & 0xFF,
            green: (Int(hex) >> 8) & 0xFF,
            blue: Int(hex) & 0xFF
        )
    }
}

extension UIDatePicker {
    /// Returns the date that reflects the displayed date clamped to the `minuteInterval` of the picker.
    public var clampedDate: Date {
        let referenceTimeInterval = self.date.timeIntervalSinceReferenceDate
        let remainingSeconds = referenceTimeInterval.truncatingRemainder(dividingBy: TimeInterval(minuteInterval*60))
        let timeRoundedToInterval = referenceTimeInterval - remainingSeconds
        return Date(timeIntervalSinceReferenceDate: timeRoundedToInterval)
    }
}
