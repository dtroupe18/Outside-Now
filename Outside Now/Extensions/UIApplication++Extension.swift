//
//  UIApplication++Extension.swift
//  Outside Now
//
//  Created by Dave on 2/15/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

extension UIApplication {
    // Allows us to get the "top" or visible viewcontroller from anywhere
    // This is useful when you want to display an alert from a class that
    // isn't the currently visible viewController
    //
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
