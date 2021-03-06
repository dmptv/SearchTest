//
//  AppDelegate.swift
//  StoreSearch
//
//  Created by 123 on 25.03.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

extension AppDelegate {
    var splitViewController: UISplitViewController {
        // initial controller
        return window!.rootViewController as! UISplitViewController
    }
    var searchViewController: SearchViewController {
        // master pane
        return splitViewController.viewControllers.first as! SearchViewController
    }
    
    var detailNavigationController: UINavigationController {
        // detail pane
        return splitViewController.viewControllers.last as! UINavigationController
    }
    
    var detailViewController: DetailViewController {
        return detailNavigationController.topViewController as! DetailViewController
    }
}


extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        print(#function)
        if displayMode == .primaryOverlay {
            // dismisses any presented view controller if the master pane becomes visible
            svc.dismiss(animated: true, completion: nil)
        }
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        customizeAppearance()
        
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        searchViewController.splitViewDetail = detailViewController
        splitViewController.delegate = self
        
        return true
    }
    
    func customizeAppearance() {
        UISearchBar.appearance().barTintColor = Colors.tintColor
        
        // for actions
        window!.tintColor = Colors.windowTintColor
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        print("--> application will resign active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}














