//
//  ListTableViewCell.swift
//  ToDoList
//
//  Created by Jakub Perich on 22/05/2019.
//  Copyright © 2019 com.jakubperich. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var deadlineLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(task: Tasks) {
        titleLbl.text = task.title
        if let date = task.dueDate {
            deadlineLbl.text = listDate(date)
        }
        categoryLbl.text = task.category
        categoryLbl.backgroundColor = uiColorFromHex(rgbValue: task.categoryColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func uiColorFromHex(rgbValue: Double) -> UIColor {
        
        let red =   CGFloat((Int(rgbValue) & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((Int(rgbValue) & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(Int(rgbValue) & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func listDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        return formatter.string(from: date)
    }
}
