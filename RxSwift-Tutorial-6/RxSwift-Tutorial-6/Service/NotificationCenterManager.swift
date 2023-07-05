//
//  NotificationCenterManager.swift
//  RxSwift-Tutorial-6
//
//  Created by Sam Sung on 2023/07/04.
//

import Foundation

struct NotificationCenterManager {
    
    static var currentBalanceChangedNotification: Notification.Name {
        return Notification.Name("valueChanged")
    }
    
    static func postCurrentBalanceChangeNotification(value: Int) {

       let currentBalanceNotification = Notification(name: currentBalanceChangedNotification,
                                            object: [
                                                "currentBalance" : value
                                            ] as [String : Any])
        NotificationCenter.default.post(currentBalanceNotification)
    }
}
