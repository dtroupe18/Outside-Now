//
//  Helper.swift
//  Outside Now
//
//  Created by Dave on 2/24/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

class Helper {
    
    static func showAlertMessage(vc: UIViewController, title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        DispatchQueue.main.async {
            vc.present(alert, animated: true, completion: nil)
        }
    }
}
