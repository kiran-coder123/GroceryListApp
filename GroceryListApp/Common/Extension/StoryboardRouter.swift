//
//  StoryboardRouter.swift
//  GroceryListApp
//
//  Created by Kiran Sonne on 27/09/22.
//


import UIKit
public protocol StoryboardRouter {
    var name: String { get }
    var controller: UIViewController { get }
}
extension StoryboardRouter {
    func getViewController<T>(T: UIViewController.Type) -> T? {
        guard let viewController = UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: String(describing: T.self)) as? T else { return nil}
        return viewController
    }
    
    func getInitialViewController() -> UIViewController? {
        guard let viewController = UIStoryboard(name: name, bundle: nil).instantiateInitialViewController() else { return nil }
        return viewController
    }
}
