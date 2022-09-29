//
//  User.swift
//  GroceryListApp
//
//  Created by Kiran Sonne on 27/09/22.
//

import Firebase
struct User {
    let uid: String
    let email: String
    
    init(authData: Firebase.User) {
        uid = authData.uid
        email = authData.email ?? ""
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
