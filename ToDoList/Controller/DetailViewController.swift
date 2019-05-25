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
    var categoriesVC = NewCategoryViewController()
    var listVC = ListViewController()
    let datePicker = UIDatePicker()
    let pickerView = UIPickerView()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryColor : Double!
    var categoryName : String!
    var dueDate : Date?
    
    var selectedTask: Tasks?{
        didSet{
            //            loadItems()
            print("Title \(String(describing: self.selectedTask?.title))")
            print("Category: \(String(describing: self.selectedTask?.category))")
            
        }
    }
    
    
    let pickCategories = ["Swift","Project","Priority","Homework","Non-work"]
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        showCategoryPicker()
        showDatePicker()
        
        if let task = selectedTask {
            
            taskName.text = task.title
            
            guard let date = task.dueDate else {
                return
            }
            datePicker.date = date
            txtDatePicker.text = fullStringFromDate(date)
            print("Date: \(date)")
            pickerTextField.text = task.category
            pickerTextField.backgroundColor = UIColor(named: "\(String(describing: task.categoryColor))")
        }
    }
    
    @IBAction func saveTaskTapped(_ sender: UIBarButtonItem) {
        guard let title = taskName.text, !title.isEmpty else {
            //      TODO: Error handling
            //            let alert = UIAlertController(title: "Task name can't be empty", message: "", preferredStyle: .alert)
            //            present(alert, animated: true, completion: nil)
            return
        }
        if let todo = self.selectedTask {
            todo.title = title
            //                todo.priotity = Int16(segmentedControl.selectedSegmentIndex)
        } else {
            let newTodo = Tasks(context: context)
            newTodo.title = title
            //                newTodo.dueDate = Date()
            newTodo.category = categoryName
            newTodo.categoryColor = categoryColor
            newTodo.completed = false
            newTodo.dueDate = nil
            
            listVC.items.insert(newTodo, at: 0)
        }
        
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error saving todo: \(error)")
        }
        
        
        
        //        let newItem = Tasks(context: self.context)
        //
        //        newItem.title = taskName.text
        //        newItem.category = "Category"
        //        newItem.categoryColor = "Blue"
        //        newItem.completed = false
        //        newItem.dueDate = datePicker.date
        //
        //        list.items.insert(newItem, at: 0)
        //
        //        list.saveTask()
        //        list.tableView.reloadData()
    }
    
    
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
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
    
    func dateFromString(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: date) // replace Date String
    }
    
    func fullStringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: date)
    }
    
    @objc func doneDatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        txtDatePicker.text = formatter.string(from: datePicker.date)
        dueDate = datePicker.date
        print(dueDate)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func cancelCategoryPicker(){
        self.view.endEditing(true)
    }
    
    func showCategoryPicker() {
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(cancelCategoryPicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([spaceButton,doneButton], animated: false)
        
        pickerTextField.inputAccessoryView = toolbar
        pickerTextField.inputView = pickerView
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let category = pickCategories[row]
        pickerTextField.text = "\(category)"
        pickerTextField.backgroundColor = self.categoriesVC.uiColorFromHex(rgbValue: categoriesVC.colorArray[row])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickCategories.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as! UILabel?
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            //color the label's background
            //            let hue = CGFloat(row)/CGFloat(pickerData.count)
            let colors = categoriesVC.colorArray[row]
            pickerLabel!.backgroundColor = self.categoriesVC.uiColorFromHex(rgbValue: colors)
            
            categoryColor = colors
        }
        let titleData = pickCategories[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.font:UIFont(name: "Helvetica", size: 18.0)!,NSAttributedString.Key.foregroundColor:UIColor.darkGray])
        pickerLabel!.attributedText = myTitle
        pickerLabel!.textAlignment = .center
        categoryName = titleData
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
