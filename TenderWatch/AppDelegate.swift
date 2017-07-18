//
//  AppDelegate.swift
//  TenderWatch
//
//  Created by lanetteam on 19/06/17.
//  Copyright © 2017 lanetteam. All rights reserved.
//

import UIKit
import IQKeyboardManager
import UserNotifications
import Google
import FBSDKCoreKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawerController = DrawerController()
    var isClient: Bool?
    var isGoogle: Bool?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //FABRIC
        Fabric.with([Crashlytics.self])
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
                
        if USER?.authenticationToken != nil
        {
            if USER?.role == RollType.client
            {
                appDelegate.isClient = true
            }else{
                appDelegate.isClient = false
            }
            setHomeViewController()
        }
        else
        {
            setUpRootVc()
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if isGoogle! {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        } else {
            return FBSDKApplicationDelegate.sharedInstance()
                .application(app,
                             open: url as URL!,
                             sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
                             annotation: options[UIApplicationOpenURLOptionsKey.annotation])

        }
        }
    
//    
//    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
//        //Even though the Facebook SDK can make this determinitaion on its own,
//        //let's make sure that the facebook SDK only sees urls intended for it,
//        //facebook has enough info already!
//    if(url.scheme!.hasPrefix("fb") && url.host == "authorize"){
//    
//        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
//        }
//       return true
//    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application,
                         open: url as URL!,
                         sourceApplication: sourceApplication,
                         annotation: annotation)
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        
//    }

    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        let centerViewController = HomeVC(nibName: "HomeVC", bundle: nil)
        
        let navigationController = UINavigationController(rootViewController: centerViewController)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let tintColor = UIColor(red: 29 / 255, green: 173 / 255, blue: 234 / 255, alpha: 1.0)
        self.window?.tintColor = tintColor
        
        self.window?.rootViewController = navigationController
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        //App activation code
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    
    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        if let key = identifierComponents.last as? String {
            if key == "Drawer" {
                return self.window?.rootViewController
            } else if key == "ExampleCenterNavigationControllerRestorationKey" {
                return (self.window?.rootViewController as! DrawerController).centerViewController
            } else if key == "ExampleRightNavigationControllerRestorationKey" {
                return (self.window?.rootViewController as! DrawerController).rightDrawerViewController
            } else if key == "ExampleLeftNavigationControllerRestorationKey" {
                return (self.window?.rootViewController as! DrawerController).leftDrawerViewController
            } else if key == "ExampleLeftSideDrawerController" {
                if let leftVC = (self.window?.rootViewController as? DrawerController)?.leftDrawerViewController {
                    if leftVC.isKind(of: UINavigationController.self) {
                        return (leftVC as! UINavigationController).topViewController
                    } else {
                        return leftVC
                    }
                }
            } else if key == "ExampleRightSideDrawerController" {
                if let rightVC = (self.window?.rootViewController as? DrawerController)?.rightDrawerViewController {
                    if rightVC.isKind(of: UINavigationController.self) {
                        return (rightVC as! UINavigationController).topViewController
                    } else {
                        return rightVC
                    }
                }
            }
        }
        
        return nil
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
    }
    
    
    // MARK:- Custom Method(s)
    
    func setUpRootVc() {
        IQKeyboardManager.shared().isEnabled = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        let nav = UINavigationController()
        let vc = HomeVC(nibName: "HomeVC", bundle: nil)
        self.window!.rootViewController = nav
        self.window!.makeKeyAndVisible()
        nav.setNavigationBarHidden(true, animated: false)
        nav.pushViewController(vc, animated: false)
    }
    
    func setHomeViewController()
    {
        // Override point for customization after application launch.
        let leftSideDrawerViewController = SideMenuVC(nibName: "SideMenuVC", bundle: nil)
        let centerViewController = TenderWatchVC(nibName: "TenderWatchVC", bundle: nil)
        
        let navigationController = UINavigationController(rootViewController: centerViewController)
        navigationController.restorationIdentifier = "ExampleCenterNavigationControllerRestorationKey"
        
        let leftSideNavController = UINavigationController(rootViewController: leftSideDrawerViewController)
        leftSideNavController.restorationIdentifier = "ExampleLeftNavigationControllerRestorationKey"
        
        self.drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: leftSideNavController)
        self.drawerController.showsShadows = true
        
        self.drawerController.restorationIdentifier = "Drawer"
        self.drawerController.maximumRightDrawerWidth = 150.0
        self.drawerController.closeDrawerGestureModeMask = .all
        self.window?.rootViewController = self.drawerController
        self.window?.makeKeyAndVisible()
    }

}

