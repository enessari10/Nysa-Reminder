//
//  ReminderAddViewController.swift
//  Nysa Reminder
//
//  Created by Enes on 23.12.2021.
//

import UIKit
import CoreData

enum ReminderAddPageState {
    case create
    case update
}

class ReminderAddViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var openGalleryButton: UIButton!
    @IBOutlet var openCamerButton: UIButton!
    @IBOutlet var reminderImageView: UIImageView!
    @IBOutlet var reminderNameTextfield: UITextField!
    @IBOutlet var reminderDescriptionTextfield: UITextField!
    @IBOutlet var reminderDatePicker: UIDatePicker!
    @IBOutlet var addreminderButton: UIButton!
    
    let notificationCenter = UNUserNotificationCenter.current()
    let dateFormater = DateFormatter()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myArray = [List]()
    var imagePicker = UIImagePickerController()
    var selectedImage: UIImage?
    
    var state: ReminderAddPageState = .create
    var reminder: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderImageView.image = UIImage(named: "user")
        imagePicker.delegate = self
        reminderNameTextfield.delegate = self
        reminderDescriptionTextfield.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
            if(!permissionGranted){
                print("Permission Denied")
            }
        }
        
        self.hideKeyboardWhenTappedAround()
        let image = reminderImageView.image
        
        reminderImageView.layer.cornerRadius = (image?.size.width)! / 2
        
        if state == .create{
            addreminderButton.setTitle("Add Reminder", for: .normal)
        }
        else{
            getReminder()
            addreminderButton.setTitle("Update Reminder", for: .normal)
        }
        
    }
    
    @IBAction func addReminderButtonPressed(_ sender: Any) {
        
        switch state {
        
        case .create:
            saveReminder()
        case .update:
            print("UPDATE")
            updateContext()
        }
    }
    
    @IBAction func openGalleryButtonPressed(_ sender: Any) {
        openGallery()
    }
    
    @IBAction func openCameraButtonPressed(_ sender: Any) {
        openCamera()
    }
    
    //MARK Functions
    func getReminder(){
        reminderNameTextfield.text = reminder?.value(forKey: "name") as? String
        reminderDescriptionTextfield.text = reminder?.value(forKey: "desc") as? String
        let picture = reminder?.value(forKey: "image")
        reminderImageView.image  = UIImage(data: picture as! Data)
        if let strDate = reminder?.value(forKey: "date") as? String {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            
            if let date = dateFormatter.date(from: strDate) {
                print("str \(strDate) \(date)")
                reminderDatePicker.date = date
            }
        }
        
    }
    
    func formattedDateGet(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == reminderNameTextfield {
            reminderDescriptionTextfield.resignFirstResponder()//
            reminderDescriptionTextfield.becomeFirstResponder()
        } else if textField == reminderDescriptionTextfield  {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func formattedDate(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY HH:mm"
        return formatter.string(from: date)
    }
    
    func updateContext(){
        print("Update Code Area Here")
        
    }
    
    func saveContext(){
        
        do{
            try self.context.save()
            self.navigationController?.popViewController(animated: true)
            
        }catch{
            print("Save Error")
        }
        
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        reminderImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func openGallery() {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func saveReminder(){
        
        let newAdd = List(context: self.context)
        newAdd.name = reminderNameTextfield.text
        newAdd.date = formattedDate(date: reminderDatePicker.date)
        newAdd.desc = reminderDescriptionTextfield.text
        selectedImage = reminderImageView.image
        let imageAsNSData = selectedImage?.jpegData(compressionQuality: 1)
        newAdd.image = imageAsNSData
        
        myArray.append(newAdd)
        saveContext()
        
        notificationCenter.getNotificationSettings { (settings) in
            
            DispatchQueue.main.async
            {
                let title = self.reminderNameTextfield.text
                let message = self.reminderDescriptionTextfield.text
                
                if(settings.authorizationStatus == .authorized)
                {
                    let content = UNMutableNotificationContent()
                    content.title = title!
                    content.body = message!
                    content.sound = .default
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.reminderDatePicker.date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { (error) in
                        if(error != nil)
                        {
                            print("Error " + error.debugDescription)
                            return
                        }
                    }
                    
                }
                else
                {
                    let ac = UIAlertController(title: "Enable Notifications?", message: "To use this feature you must enable notifications in settings", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Settings", style: .default)
                    { (_) in
                        guard let setttingsURL = URL(string: UIApplication.openSettingsURLString)
                        else
                        {
                            return
                        }
                        
                        if(UIApplication.shared.canOpenURL(setttingsURL))
                        {
                            UIApplication.shared.open(setttingsURL) { (_) in}
                        }
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in}))
                }
            }
        }
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
