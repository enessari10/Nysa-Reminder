//
//  AddReminderTableViewCell.swift
//  Nysa Reminder
//
//  Created by Enes on 16.12.2021.
//

import UIKit
import CoreData
import UserNotifications

protocol ViewShowDelegate {
    func viewData(reminderName: String, reminderDesc: String, reminderDate:Date)
    func openGallery()
    func openCamera()
}

class AddReminderTableViewCell: UITableViewCell, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet var reminderName: UITextField!
    @IBOutlet var reminderDesc: UITextField!
    @IBOutlet var reminderDate: UIDatePicker!
    @IBOutlet var reminderPhoto: UIImageView!
    
    let notificationCenter = UNUserNotificationCenter.current()
    var delegate : ViewShowDelegate?
    let imagePicker = UIImagePickerController()

    override func awakeFromNib() {
        super.awakeFromNib()
        imagePicker.delegate = self
        reminderDesc.delegate = self
        reminderName.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
                if(!permissionGranted){
                        print("Permission Denied")
                    }
            }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        print("enes deneme")
        guard let name = reminderName.text else {return}
        guard let desc = reminderDesc.text else {return}
        delegate?.viewData(reminderName: name, reminderDesc: desc, reminderDate: reminderDate.date)

    }
 
    @IBAction func openGalleryButtonPressed(_ sender: Any) {
        delegate?.openGallery()
    }
    
    @IBAction func openCameraButtonPressed(_ sender: Any) {
        delegate?.openCamera()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       let nextTag = textField.tag + 1
     let nextTF = textField.superview?.viewWithTag(nextTag) as UIResponder?
       if nextTF != nil {
          nextTF?.becomeFirstResponder()
       } else {
          textField.resignFirstResponder()
       }
       return false
    }
}


