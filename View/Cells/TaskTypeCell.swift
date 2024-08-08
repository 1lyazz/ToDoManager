//  TaskTypeCell.swift
//  To-Do Manager
//  Created by Ilya Zablotski

import UIKit

class TaskTypeCell: UITableViewCell {
    @IBOutlet var typeTitle: UILabel!
    @IBOutlet var typeDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
