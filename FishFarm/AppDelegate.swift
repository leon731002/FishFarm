//
//  AppDelegate.swift
//  FishFarm
//
//  Created by Leon on 2018/5/25.
//  Copyright © 2018年 Leon. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    private var supportPush: Bool = false
    
    private func registerPush(_ application: UIApplication) {
        RegisterData.sharedInstance.setPushNotificationId("")
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                }
                else{
                    //Do stuff if unsuccessful...
                }
            })
        }
        else{ //If user is not on iOS 10 use the old methods we've been using
            if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
                
                
                DispatchQueue.main.async {
                    let settings = UIUserNotificationSettings(types: [.alert, .badge], categories: nil)
                    application.registerUserNotificationSettings(settings)
                    application.registerForRemoteNotifications()
                }
                
            }
            
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if supportPush {
            self.registerPush(application)
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = ( deviceToken.map { String(format: "%02.2hhx", $0) }.joined() as NSString ) as String
        RegisterData.sharedInstance.setPushNotificationId(token)
        self.autoConnectAnExistingServer()
    }
    
    private func checkIfServerIsAvailable(_ serverIP: String, completion: @escaping (Bool) -> Void) {
        HttpRequestFactory.sharedInstance.sendHttpRequest(serverIP: serverIP, requestType: .register, querySource: RegisterData.sharedInstance.getJsonString()) {
            (result: Any) in
            if let connected = result as? Bool {
                completion(connected)
            }
            else {
                completion(false)
            }
        }
    }
    
    private func autoConnectAnExistingServer() {
        DispatchQueue.main.async {
            let ip = SharedPreferenceManager.sharedInstance.getValueByKey(.ip)
            if ip != "" {
                self.checkIfServerIsAvailable(ip) {
                    (_ : Bool) in
                    
                }
            }
            
        }
        
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
        if supportPush {
            self.registerPush(application)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

