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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCategories()
        loadTasks()
        sortedTasks = items.sorted{
            ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture)
        }
        
        if categories.isEmpty {
            
            for i in 0 ..< Helper.app.defaultCategories.count {
                let newCategory = Categories(context: context)
                newCategory.categoryColor = Helper.app.defaultColors[i]
                newCategory.categoryName = Helper.app.defaultCategories[i]
                categories.append(newCategory)
            }
            
            do {
                try context.save()
            } catch {
                print("Error saving todo: \(error)")
            }
        }
        scheduleLocal()
        tableView.reloadData()
    }
    
    
    //MARK: TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedTasks.count == 0 {
            self.tableView.setEmptyMessage("All tasks are completed")
        } else {
            self.tableView.restore()
        }
        return sortedTasks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ListTableViewCell {
            
            let item = sortedTasks[indexPath.row]
            cell.setCell(task: item)
            if item.completed {
                cell.backgroundColor = #colorLiteral(red: 0.8320295215, green: 0.9826709628, blue: 0, alpha: 1)
            } else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            return cell
        }
        return UITableViewCell()
    }
    
//    Segues to subpages - programatically and via storyboard
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
                destinationVC.selectedTask = sortedTasks[indexPath.row]
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toDetail", sender: UITabBarItem.self)
    }
    
//    Delete task swipe action
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            
            let item = sortedTasks[indexPath.row]
            context.delete(item)
            sortedTasks.remove(at: indexPath.row)
            
            do {
                try context.save()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                scheduleLocal()
                loadTasks()
                
            } catch {
                print("Error deleting items with \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskCompletion = sortedTasks[indexPath.row].completed ? "Restart" : "Complete"
        let action = UIContextualAction(style: .normal, title: taskCompletion) { (action, view, completion) in
            self.sortedTasks[indexPath.row].completed = !self.sortedTasks[indexPath.row].completed

            do{
                try self.context.save()
                self.scheduleLocal()
                completion(true)
            }catch {
                print("Error saving item with \(error)")
            }
            tableView.reloadData()
        }
        action.backgroundColor = .green

        return UISwipeActionsConfiguration(actions: [action])
    }
    
//    Loads Tasks entity from CoreData
    func loadTasks(){
        let request: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        do {
            items = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
//    Loads Categories entity from CoreData

    func loadCategories(){
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    
    //   Setup local notifications - you will get local notification at the task deadline if deadline is set.
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
                    content.sound = UNNotificationSound.default
                    let date = items[i].dueDate!
                    var triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    triggerDate.second = 0
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request)
                    print("Notification created: \(content.body)")
                    print("Trigger date: \(triggerDate)")
                }
            }
        }
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
