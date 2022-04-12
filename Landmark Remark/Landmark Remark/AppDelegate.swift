//
//  AppDelegate.swift
//  Landmark Remark
//
//  Created by JD on 11/4/2022.
//

import UIKit
import Firebase


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Navigation Controller
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.makeKeyAndVisible()
        let rootView = MainMenuViewController()
        let navigationController = UINavigationController(rootViewController: rootView)
        self.window?.rootViewController = navigationController
        
        // Firebase
        FirebaseApp.configure()
        db = Firestore.firestore()
        
        return true
    }


}

