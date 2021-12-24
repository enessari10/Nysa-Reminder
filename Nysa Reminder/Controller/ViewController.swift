//
//  ViewController.swift
//  Nysa Reminder
//
//  Created by Enes on 15.12.2021.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet var myTable: UITableView!
    @IBOutlet var dateButton: UIButton!
    @IBOutlet var alfabeticButton: UIButton!
    @IBOutlet var reverseButton: UIButton!
    
    let notificationCenter = UNUserNotificationCenter.current()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var myArray = [List]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTable.delegate = self
        myTable.dataSource = self
        getData()
        dateButton.layer.borderColor = UIColor.systemPink.cgColor
        dateButton.layer.cornerRadius = 1
        
        alfabeticButton.layer.borderColor = UIColor.systemPink.cgColor
        alfabeticButton.layer.cornerRadius = 1
        
        reverseButton.layer.borderColor = UIColor.systemPink.cgColor
        reverseButton.layer.cornerRadius = 1
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getData()

    }
   
    
    
    func getData(){
        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        let request : NSFetchRequest<List> = List.fetchRequest()
        request.sortDescriptors = sortDescriptors

        do{
            myArray = try context.fetch(request)
            myTable.reloadData()
        }catch{
            print("Error")
        }
    }
    
    @IBAction func showAddReminderVC(_ sender: Any) {
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReminderVC") as? ReminderAddViewController else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func shortDateButtonPressed(_ sender: Any) {
        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        let request : NSFetchRequest<List> = List.fetchRequest()
        request.sortDescriptors = sortDescriptors

        do{
            myArray = try context.fetch(request)
            myTable.reloadData()
        }catch{
            print("Error")
        }
    }
    @IBAction func shortAlfabeticButtonPressed(_ sender: Any) {
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        let request : NSFetchRequest<List> = List.fetchRequest()
        request.sortDescriptors = sortDescriptors

        do{
            myArray = try context.fetch(request)
            myTable.reloadData()
        }catch{
            print("Error")
        }
    }
    @IBAction func shortReverseButtonPressed(_ sender: Any) {
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        let request : NSFetchRequest<List> = List.fetchRequest()
        request.sortDescriptors = sortDescriptors

        do{
            myArray = try context.fetch(request)
            myTable.reloadData()
        }catch{
            print("Error")
        }
    }
}




extension ViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddReminderVC") as? ReminderAddViewController else { return }
        vc.state = .update
        vc.reminder = myArray[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell") as!  MainTableViewCell
        cell.reminderName.text = myArray[indexPath.row].name
        cell.reminderDesc.text = myArray[indexPath.row].desc
        cell.reminderTime.text = myArray[indexPath.row].date
        cell.reminderPhoto.image = UIImage(data: myArray[indexPath.row].image!)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView,trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        let TrashAction = UIContextualAction(style: .normal, title:  "Sil", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.context.delete(self.myArray[indexPath.row])
            self.myArray.remove(at: indexPath.row)
            if self.myArray.count == 0{
                self.myTable.isHidden = true
                self.myTable.reloadData()
            }else{
                self.myTable.isHidden = false
                self.myTable.reloadData()
            }
            success(true)
        })
        TrashAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [TrashAction])
    }
 
}
