//
//  SettingsTableViewController.swift
//  ToDoList
//
//  Created by Jakub Perich on 24/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var switcher: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: "SwitchState") != nil) {
            switcher.isOn = defaults.bool(forKey: "SwitchState")
        }
    }
    
    // MARK: - Table view data source
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        
        if switcher.isOn {
            defaults.set(true, forKey: "SwitchState")
            registerLocal()
        } else {
            defaults.set(false, forKey: "SwitchState")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //    Get permission to send notifications
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Permission granted")
                self.showAlertAndDismiss(title: "Success", message: "You will get notification for each task on the deadline date", vc: self)
            } else {
                print("Permission denied")
            }
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
    
    
}
