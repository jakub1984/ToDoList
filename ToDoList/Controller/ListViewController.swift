//
//  ListViewController.swift
//  ToDoList
//
//  Created by Jakub Perich on 22/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
    
    var items = [Tasks]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTasks()
        tableView.reloadData()
    }
    
    
    //MARK: TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ListTableViewCell {
            let item = items[indexPath.row]
            cell.setCell(task: item)
            //        cell.accessoryType = item.completed ? .checkmark : .none
            if item.completed {
                cell.backgroundColor = .green
            } else {
                cell.backgroundColor = .white
            }
            return cell
        }
        return UITableViewCell()
    }
    
    @IBAction func settingsIconTapped(_ sender: UIBarButtonItem) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let settingsViewController = mainStoryboard.instantiateViewController(withIdentifier:"settingsVC") as? NewCategoryViewController
            else {
            print("Can't find view controller")
            return
        }
        navigationController?.pushViewController(settingsViewController, animated: true)
        
    }
    
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: tableView.cellForRow(at: indexPath))
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? DetailViewController {
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedTask = items[indexPath.row]
        }
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toDetail", sender: UITabBarItem.self)

        
//        var textField = UITextField()
//
//        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
//
//        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
//
//            let newItem = Tasks(context: self.context)
//
//
//            newItem.title = textField.text!
//            newItem.category = "Category"
//            newItem.categoryColor = "Blue"
//            newItem.completed = false
//            newItem.dueDate = nil
//
//            self.items.insert(newItem, at: 0)
//
//            self.saveTask()
//
//        }
//
//        alert.addAction(action)
//
//        alert.addTextField { (field) in
//            textField = field
//            textField.placeholder = "Add a New Item"
//        }
//        present(alert, animated: true, completion: nil)
        
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            
            let item = items[indexPath.row]
            items.remove(at: indexPath.row)
            context.delete(item)
            
            do {
                try context.save()
            } catch {
                print("Error deleting items with \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic) 
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskCompletion = items[indexPath.row].completed ? "Restart" : "Complete"
        let action = UIContextualAction(style: .normal, title: taskCompletion) { (action, view, completion) in
            
            action.backgroundColor = .green
            self.items[indexPath.row].completed = !self.items[indexPath.row].completed
            print("Completed: \(self.items[indexPath.row].completed)")

            do{
                try self.context.save()
                completion(true)
            }catch {
                print("Error saving item with \(error)")
            }
            tableView.reloadData()
            
            
            
            
        }
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//
//        if items[indexPath.row].completed {
//            cell.backgroundColor = .green
//        } else {
//            cell.backgroundColor = .white
//        }

        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    func loadTasks(){
        let request: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        do {
            items = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    func saveTask() {
        do{
            try context.save()
        }catch {
            print("Error saving item with \(error)")
        }
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
