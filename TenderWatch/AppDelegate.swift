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
import UserNotifications
import Alamofire
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawerController = DrawerController()
	var isClient: Bool?
    var isGoogle: Bool?
    var token: String!
    var notiNumber: Int!
    
    private let stripePublishableKey: String = "pk_test_mjxYxMlj4K2WZfR6TwlHdIXW"
    private let appleMerchantIdentifier: String = "merchant.com.tenderWatch.imtiaz"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //PayPal Config.
        PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "AR2fso-1K52oJUbAG-R3eZ3bk3O8PeY7gfUMqZAypVzqPK2DWV-9Q7S-SZxLe13sI68RFWJ9QAuZcd4-",
                                                                PayPalEnvironmentSandbox: "AdYtcg05haUBRoc5ljmkM-tBorYLNvLem5Iy6UD6Sf-8wAV_uUpKkOwvXeuIn3-m1lkfmAHzLchxod_r"])
        
        //Stripe 
        
        STPPaymentConfiguration.shared().companyName = "TenderWatch by @Imtiaz"

        if !stripePublishableKey.isEmpty {
            STPPaymentConfiguration.shared().publishableKey = stripePublishableKey
        }
        
        if !appleMerchantIdentifier.isEmpty {
            STPPaymentConfiguration.shared().appleMerchantIdentifier = appleMerchantIdentifier
        }
        
        
        // Stripe theme configuration
        STPTheme.default().primaryBackgroundColor = .appVeryLightGrayColor
        STPTheme.default().primaryForegroundColor = .appDarkBlueColor
        STPTheme.default().secondaryForegroundColor = .appDarkGrayColor
        STPTheme.default().accentColor = .appGreenColor
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        //FABRIC
        Fabric.with([Crashlytics.self, STPAPIClient.self])
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
                
        if USER?.authenticationToken != nil {
            if USER?.role == RollType.client {
                appDelegate.isClient = true
            } else {
                appDelegate.isClient = false
            }
            setHomeViewController()
        }
        else {
            setUpRootVc()
        }
        
        registerForPushNotifications()
        notiNumber = application.applicationIconBadgeNumber
        if application.applicationIconBadgeNumber > 0 {
            badgeCount()
            application.applicationIconBadgeNumber = 0
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let stripeHandled = Stripe.handleURLCallback(with: url)
        if (stripeHandled) {
            return true
        } else {
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
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if !isGoogle! {
            return FBSDKApplicationDelegate.sharedInstance()
                .application(application,
                             open: url as URL!,
                             sourceApplication: sourceApplication,
                             annotation: annotation)

        }
        return true
    }
    
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
        badgeCount()

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if USER?.authenticationToken != nil {
            appDelegate.setHomeViewController()
        }
        appDelegate.notiNumber = application.applicationIconBadgeNumber
        application.applicationIconBadgeNumber = 0
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
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        print(deviceID)
        token = tokenParts.joined()
        print("Device Token: \(token!)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        token = "902197b814b72dc923d4573e11ce783fdbafa622"
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        switch application.applicationState {
        case .active:
            print("active")
            break
        case .background:
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = self
            } else {
                // Fallback on earlier versions
            }
            application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
            break
        default: //inactive
            switch userInfo["notificationType"]! as! String {
            case "upload","amended","delete":
                self.setHomeViewController()
                break
            default: // interested
                self.setUpNotificationVC()
                print("interested")
            }
        }
        print("Notification Arrived")
        print(userInfo)
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
    
    func setUpNotificationVC() {
        let leftSideDrawerViewController = SideMenuVC(nibName: "SideMenuVC", bundle: nil)
        let centerViewController = UserDetailVC(nibName: "UserDetailVC", bundle: nil)
        
        let navigationController = UINavigationController(rootViewController: centerViewController)
        navigationController.restorationIdentifier = "ExampleCenterNavigationControllerRestorationKey"
        
        let leftSideNavController = UINavigationController(rootViewController: leftSideDrawerViewController)
        leftSideNavController.restorationIdentifier = "ExampleLeftNavigationControllerRestorationKey"
        
        self.drawerController = DrawerController(centerViewController: navigationController, leftDrawerViewController: leftSideNavController)
        self.drawerController.showsShadows = true
        
        self.drawerController.restorationIdentifier = "Drawer"
        self.drawerController.maximumLeftDrawerWidth = UIScreen.main.bounds.width / 1.25
        self.drawerController.closeDrawerGestureModeMask = .all
        self.window?.rootViewController = self.drawerController
        self.window?.makeKeyAndVisible()
    }
    
    func setHomeViewController() {
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
        self.drawerController.maximumLeftDrawerWidth = UIScreen.main.bounds.width / 1.25
        self.drawerController.closeDrawerGestureModeMask = .all
        self.window?.rootViewController = self.drawerController
        self.window?.makeKeyAndVisible()
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert , .sound]) { (granted, error) in
                
                guard granted else { return }
                
                // 1
                
                let viewAction = UNNotificationAction(identifier: "View",
                                                      title: "Contractor Detail",
                                                      options: [.foreground])
                let cancel = UNNotificationAction(identifier: "", title: "Cancel", options: UNNotificationActionOptions.destructive)
                // 2
                let newsCategory = UNNotificationCategory(identifier: "Contractor_Detail",
                                                          actions: [viewAction, cancel],
                                                          intentIdentifiers: ["Category"],
                                                          options: [])
                // 3
                UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
                
                if granted {
                    UIApplication.shared.registerForRemoteNotifications();
                }
            }
        } else {
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound];
            let setting = UIUserNotificationSettings(types: type, categories: nil);
            UIApplication.shared.registerUserNotificationSettings(setting);
            UIApplication.shared.registerForRemoteNotifications();
        }
    }
    
    func badgeCount() {
        if USER?.authenticationToken != nil {
            Alamofire.request(READ_NOTIFY, method: .put, parameters: [:], encoding: JSONEncoding.default, headers: ["Authorization":"Bearer \(UserManager.shared.user!.authenticationToken!)"]).responseJSON(completionHandler: { (resp) in
            })
        }
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == "View" {
            setUpNotificationVC()
        } else {
            switch userInfo["notificationType"]! as! String {
                case "upload","amended","deleted":
                    self.setHomeViewController()
                    break
                default:
//                    self.setUpNotificationVC()
                    self.setHomeViewController()
                    break
            }
        }
    }
}


