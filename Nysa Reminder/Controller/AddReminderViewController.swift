//
//  AddReminderViewController.swift
//  Nysa Reminder
//
//  Created by Enes on 16.12.2021.
//

import UIKit

class AddReminderViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet var addReminderTable: UITableView!
    
    let notificationCenter = UNUserNotificationCenter.current()
    let dateFormater = DateFormatter()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myArray = [List]()
    var imagePicker = UIImagePickerController()
    var state : String = ""
    var selectedImage: UIImage?
    var pageStateUpdate = PageState.update
       
    enum PageState : String{
        case create = "Create"
        case update = "Update"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addReminderTable.delegate = self
        addReminderTable.dataSource = self
        selectedImage = UIImage(named: "user")
        
        switch pageStateUpdate {
        case .create:
            print("Create")
        case .update:
            print("Update")
        }
    }
    
    @IBAction func openCameraButtonPressed(_ sender: Any) {
    }
    
    func saveData(reminderName : String, reminderDate : Date, reminderDesc : String){
        
        let newAdd = List(context: self.context)
        newAdd.name = reminderName
        newAdd.date = formattedDate(date: reminderDate)
        newAdd.desc = reminderDesc
        let imageAsNSData = selectedImage?.jpegData(compressionQuality: 1)
        newAdd.image = imageAsNSData
        
        myArray.append(newAdd)
        saveContext()
        
        notificationCenter.getNotificationSettings { (settings) in
            
            DispatchQueue.main.async
            {
                let title = reminderName
                let message = reminderDesc
                
                if(settings.authorizationStatus == .authorized)
                {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    content.sound = .default
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
                    
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
        func formattedDate(date: Date) -> String
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/YYYY HH:mm"
            return formatter.string(from: date)
        }
        
        
        func saveContext(){
            do{
                try self.context.save()
                self.navigationController?.popViewController(animated: true)
                
            }catch{
                print("Save Error")
            }
            
        }
        
    }
}
extension AddReminderViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddReminderTableViewCell") as? AddReminderTableViewCell else { return UITableViewCell() }
        cell.delegate=self
        cell.reminderPhoto.image = selectedImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 433
    }
    
    
}

extension AddReminderViewController : ViewShowDelegate {
    func viewData(reminderName: String, reminderDesc: String, reminderDate: Date) {
        self.saveData(reminderName: reminderName, reminderDate: reminderDate, reminderDesc: reminderDesc)
        
    }
    
    func openCamera() {
        print("camera")
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
        
        self.selectedImage = image
        self.addReminderTable.reloadData()
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
}
