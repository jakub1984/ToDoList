//
//  ListViewController.swift
//  ToDoList
//
//  Created by Jakub Perich on 22/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ListViewController: UITableViewController {
    
    var items = [Tasks]()
    var categories = [Categories]()
    var sortedTasks = [Tasks]()
    var defaultCategories : [String] = ["Swift","Project","Priority","Homework","Non-work"]
    var defaultColors : [Double] = [0x79A700, 0xF68B2C, 0xF5522D, 0xE2B400, 0xFF6E83]
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if categories.isEmpty {
            
            for i in 0 ..< defaultCategories.count {
//                print("Category: \(defaultCategories[i]) colors: \(defaultColors[i])")
                let newCategory = Categories(context: context)
                newCategory.categoryColor = defaultColors[i]
                newCategory.categoryName = defaultCategories[i]
                categories.append(newCategory)
            }
            
            do {
                try context.save()
                print("saved")
            } catch {
                print("Error saving todo: \(error)")
            }
            print(categories)
        }

        loadTasks()
        print("item: \(items)")
        loadCategories()
        scheduleLocal()

        tableView.reloadData()
        
    }
    
    @objc func scheduleLocal() {
        let switchOn: Bool = (UserDefaults.standard.value(forKey: "SwitchState") as? Bool ?? false)
        
        if switchOn {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            
            print("ScheduleLocal started")
            
            for i in 0 ..< items.count {
                if items[i].dueDate != nil && items[i].completed == false {
                    let content = UNMutableNotificationContent()
                    content.title = "You have task to complete:"
                    content.body = items[i].title!
                    content.categoryIdentifier = "todo"
                    //            content.userInfo = ["customData": "fizzbuzz"]
                    content.sound = UNNotificationSound.default
                    let date = items[i].dueDate!
                    var triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    triggerDate.second = 0
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                    //            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request)
                    print("Notification created: \(content.body)")
                    print("Trigger date: \(triggerDate)")
                }
            }
        }
    }
    
    //MARK: TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            self.tableView.setEmptyMessage("All tasks are completed")
        } else {
            self.tableView.restore()
        }
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ListTableViewCell {
            sortedTasks = items.sorted{
                ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture)
            }
            let item = sortedTasks[indexPath.row]
            cell.setCell(task: item)
            //        cell.accessoryType = item.completed ? .checkmark : .none
            if item.completed {
                cell.backgroundColor = #colorLiteral(red: 0.8320295215, green: 0.9826709628, blue: 0, alpha: 1)
            } else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
            print("indexpath: \(indexPath)")

            destinationVC.selectedTask = sortedTasks[indexPath.row]
        }
            
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toDetail", sender: UITabBarItem.self)
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            
            let item = sortedTasks[indexPath.row]
            items.remove(at: indexPath.row)
            context.delete(item)
            
            do {
                try context.save()
                scheduleLocal()
            } catch {
                print("Error deleting items with \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic) 
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskCompletion = sortedTasks[indexPath.row].completed ? "Restart" : "Complete"
        let action = UIContextualAction(style: .normal, title: taskCompletion) { (action, view, completion) in
            
            self.sortedTasks[indexPath.row].completed = !self.sortedTasks[indexPath.row].completed

            do{
                try self.context.save()
                completion(true)
                self.scheduleLocal()

            }catch {
                print("Error saving item with \(error)")
            }
            tableView.reloadData()
        }
        action.backgroundColor = .green
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
    
    func loadCategories(){
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        
        do {
            categories = try context.fetch(request)
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

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
