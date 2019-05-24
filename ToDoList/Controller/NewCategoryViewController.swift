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
    let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var slider: UISlider!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        selectedColorView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(slider.value)])

    }
    
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    

}
