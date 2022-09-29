//
//  OnlineUsersTableViewController.swift
//  GroceryListApp
//
//  Created by Kiran Sonne on 27/09/22.
//

import UIKit
import Firebase

class OnlineUsersTableViewController: UITableViewController {

    //MARK: Constants
    var userCell = "UserCell"
    
    //MARK: Properties
    var currentUser: [String] = []
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let usersRef = Database.database().reference(withPath: "online")
    var usersRefObservers: [DatabaseHandle] = []

    
    
    
    //MARK: Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()
         
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 1
        let childAdded = usersRef
          .observe(.childAdded) { [weak self] snap in
            // 2
            guard
              let email = snap.value as? String,
              let self = self
            else { return }
            self.currentUser.append(email)
            // 3
            let row = self.currentUser.count - 1
            // 4
            let indexPath = IndexPath(row: row, section: 0)
            // 5
            self.tableView.insertRows(at: [indexPath], with: .top)
          }
        usersRefObservers.append(childAdded)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        usersRefObservers.forEach(usersRef.removeObserver(withHandle:))
        usersRefObservers = []

    }

    // MARK: - Table view delegate methods
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return currentUser.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUser[indexPath.row]
        cell.textLabel?.text = "\(onlineUserEmail)"
        return cell
     }
    
    @IBAction func signOutDidTouch(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
        // 1
        guard let user = Auth.auth().currentUser else { return }
        let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
        // 2
        onlineRef.removeValue { error, _ in
          // 3
          if let error = error {
            print("Removing online failed: \(error)")
            return
          }
          // 4
          do {
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
          } catch let error {
            print("Auth sign out failed: \(error)")
          }
        }

    }
}
