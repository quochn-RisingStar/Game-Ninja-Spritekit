//
//  AppDelegate.swift
//  Game
//
//  Created by Nitrotech Asia on 04/04/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var shared = AppDelegate()
    var window: UIWindow?
    var isX: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436:
            AppDelegate.shared.isX = true
        default:
            AppDelegate.shared.isX = false
        }
        return true
    }
}

