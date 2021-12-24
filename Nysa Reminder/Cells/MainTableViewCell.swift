//
//  MainTableViewCell.swift
//  Nysa Reminder
//
//  Created by Enes on 16.12.2021.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet var reminderName: UILabel!
    @IBOutlet var reminderDesc: UILabel!
    @IBOutlet var reminderTime: UILabel!
    @IBOutlet var reminderPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let image = reminderPhoto.image
        reminderPhoto.layer.cornerRadius = (image?.size.height)! / 7
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
