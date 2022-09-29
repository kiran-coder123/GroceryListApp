//
//  GroceryListTableViewController.swift
//  GroceryListApp
//
//  Created by Kiran Sonne on 27/09/22.
//

import UIKit
import Firebase
class GroceryListTableViewController: UITableViewController {
    
    //MARK: Constants
    let listToUsers = "ListToUsers"
    var handle: AuthStateDidChangeListenerHandle?

    // creating connection to firebase
    let reference = Database.database().reference(withPath: "grocery-items")
    var refObservers: [DatabaseHandle] = []
    
    let usersRef = Database.database().reference(withPath: "online")
    var usersRefObservers: [DatabaseHandle] = []

    
    
    
    
    //MARK: Properties
    var items: [GroceryItem] = []
    var user: User?
    var onlineUserCount = UIBarButtonItem()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: Life cycles Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = false
        onlineUserCount = UIBarButtonItem(title: "1", style: .plain, target: self, action: #selector(onlineUserCountDidTouch))
        onlineUserCount.tintColor = .black
        navigationItem.leftBarButtonItem = onlineUserCount
        user = User(uid: "myID", email: "kiransonne04@gmail.com")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        let completed = reference.queryOrdered(byChild: "completed").observe(.value) { snapshot in
            var newItems: [GroceryItem] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let groceryItem = GroceryItem(snapshot: snapshot) {
                    newItems.append(groceryItem)
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        }
        // 1
        let currentUserRef = self.usersRef.child(user!.uid)
        // 2
        currentUserRef.setValue(user?.email)
        // 3
        currentUserRef.onDisconnectRemoveValue()
        
        let users = usersRef.observe(.value) { snapshot in
          if snapshot.exists() {
            self.onlineUserCount.title = snapshot.childrenCount.description
          } else {
            self.onlineUserCount.title = "0"
          }
        }
        usersRefObservers.append(users)

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refObservers.forEach(reference.removeObserver(withHandle:))
        refObservers = []
        guard let handle = handle else { return }
        Auth.auth().removeStateDidChangeListener(handle)
        
        usersRefObservers.forEach(usersRef.removeObserver(withHandle:))
        usersRefObservers = []

        

    }
    
    //MARK: UITableView delegates methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser
        toggleCellCheckbox(cell,isCompleted: groceryItem.completed)
        return cell
    }
 
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        let groceryItem = items[indexPath.row]
        groceryItem.ref?.removeValue()
      }
    }
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
       let groceryItem = items[indexPath.row]
        let toggledCompletion = !groceryItem.completed
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
       groceryItem.ref?.updateChildValues([
        "completed": toggledCompletion
       ])
        tableView.reloadData()
    }
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .gray
            cell.detailTextLabel?.textColor = .gray
        }
    }
    //MARK: Add Item
    
    @IBAction func addItemButtonClicked(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Grocery Item", message: "Add an Item", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first,let text = textField.text,let user = self.user
            else { return }
            
            let groceryItem = GroceryItem(name: text, addedByUser: user.email, completed: false)
            
            // MARK: Adding new items to the list
            
            let groceryItemRef =  self.reference.child(text.lowercased())
            groceryItemRef.setValue(groceryItem.toAnyObject())
            
            /*
             let groceryItemRef = self.ref.child(text.lowercased())
             groceryItemRef.setValue(groceryItem.toAnyObject())
             */
            self.items.append(groceryItem)
            print(groceryItem.name)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    @objc func onlineUserCountDidTouch() {
        performSegue(withIdentifier: listToUsers, sender: nil)
    }
}
