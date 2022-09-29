//
//  GroceryItem.swift
//  GroceryListApp
//
//  Created by Kiran Sonne on 27/09/22.
//

import Firebase
struct GroceryItem {
    let ref: DatabaseReference!
    let key: String
    let name: String
    let addedByUser: String
    var completed: Bool
    
    //MARK: Initialize with raw data
    init(name: String, addedByUser: String,completed: Bool,key: String = "") {
        self.ref = nil
        self.key = key
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    //MARK: Initialize with firebase DataSnapshot
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: AnyObject], let name = value["name"] as? String, let addedByUser = value["addedByUser"] as? String, let completed = value["completed"] as? Bool else {
            return nil
        }
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
    }
    
    //MARK: Convert GroceryItem to AnyObject
    func toAnyObject() -> Any {
        return [
            "name": name,
            "addedByUser": addedByUser,
            "completed": completed
        ]
    }
}

