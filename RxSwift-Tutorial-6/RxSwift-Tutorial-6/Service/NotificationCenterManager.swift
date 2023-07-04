//
//  NotificationCenterManager.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/04.
//

import Foundation

struct NotificationCenterManager {
    
    static var currentBalanceChangeNotification: Notification.Name {
        return Notification.Name("valueChanged")
    }
    
    static func postCurrentBalanceChangeNotification(value: Int) {

       let currentBalanceNotification = Notification(name: currentBalanceChangeNotification,
                                            object: [
                                                "currentBalance" : value
                                            ] as [String : Any])
        NotificationCenter.default.post(currentBalanceNotification)
    }

}
