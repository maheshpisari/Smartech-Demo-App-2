//
//  AppDelegate.swift
//  Smartech Demo
//
//  //

import UIKit
import Firebase
import CoreLocation
import Smartech
import SmartPush
import UserNotifications
import UserNotificationsUI
import IQKeyboardManagerSwift
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SmartechDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, UINavigationBarDelegate {
    
    var window: UIWindow?
    
    var VC:ViewController?
    var navigationVC:UINavigationController?
    var tabBar:UITabBarController?
    
    var locationManager = CLLocationManager()
    var isUserLoggedIn: Bool {
        return UserDefaults.standard.value(forKey: "userLogged") != nil
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if isUserLoggedIn == true {
            
            print("Already logged in")
            moveToTabbar(1)
//
            print("\(UserDefaults.standard.value(forKey: "userLogged")!)")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let tabBar = storyBoard.instantiateViewController(withIdentifier: "tabBarSegue") as! UITabBarController
            tabBar.modalPresentationStyle = .fullScreen

            UIApplication.shared.windows.first?.rootViewController? = tabBar
            UIApplication.shared.windows.first?.makeKeyAndVisible()
//
        }
        
        
        Smartech.sharedInstance().initSDK(with: self, withLaunchOptions: launchOptions)
        Smartech.sharedInstance().setDebugLevel(.verbose)
        Hansel.enableDebugLogs()
        SmartPush.sharedInstance().registerForPushNotificationWithDefaultAuthorizationOptions()
        Smartech.sharedInstance().trackAppInstallUpdateBySmartech()
        
        UNUserNotificationCenter.current().delegate = self
        
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        self.getLocations()
        
        
        return true
        
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SmartPush.sharedInstance().didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        SmartPush.sharedInstance().didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print(url)
        return true
    }
    
    
    //MARK:- UNUserNotificationCenterDelegate Methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        SmartPush.sharedInstance().willPresentForegroundNotification(notification)
        completionHandler([.badge, .sound, .alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("SMT-APP (didReceive):- \(response)")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(0.5 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            SmartPush.sharedInstance().didReceive(response)
            completionHandler()
        })
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("SMT -BACKGROUND DELIVER", userInfo)
        
    }
    //MARK:- SmartechDelegate Method
    func handleDeeplinkAction(withURLString deeplinkURLString: String, andCustomPayload customPayload: [AnyHashable : Any]?) {
        //...
        
        print("Deeplink: \(deeplinkURLString)")
        if customPayload != nil {
            print("Custom Payload: \(customPayload!)")
            
        }
        
        //...
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handleBySmartech:Bool = Smartech.sharedInstance().application(app, open: url, options: options)
        print("URL:\(url)")
        //            ....
        if let scheme = url.scheme,
           scheme.localizedCaseInsensitiveCompare("smartechdemo") == .orderedSame,
           var finalHost = url.host {
            print("Final Host: \(finalHost)")
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
                print("TEST URL: ",parameters[$0.value!] as Any )
            }
            
            if finalHost == "px"{
                let tabBarController = UITabBarController()

                navigationVC?.pushViewController(tabBarController, animated: true)
                
////            smartechdemo://px
                (rootController: tabBarController, window:UIApplication.shared.keyWindow)
            }
            
        }
        
        
        if(!handleBySmartech) {
            //Handle the url by the app
            
        }else{
            return handleBySmartech
        }
        
        
        return ((GIDSignIn.sharedInstance.handle(url)) != nil)
    }
    
    func moveToTabbar(_ withIndex : Int){
        let tabBarController = UITabBarController()
        tabBarController.selectedIndex = 1
        
        (rootController: tabBarController, window:UIApplication.shared.keyWindow)
    }
    func pushTabBarController(){
        
    }
    
    
    func getLocations() -> Void {
        //        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.authorizationStatus() == .restricted {
            
        }
        if CLLocationManager.authorizationStatus() == .denied {
            
        }
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //        print("Error is ", error);
        //        if CLLocationManager.authorizationStatus() == .restricted {
        //            print("restricted");
        //        }
        //        if CLLocationManager.authorizationStatus() == .denied {
        //            print("denied");
        //        }
        //        if CLLocationManager.authorizationStatus() == .notDetermined {
        //            print("notDetermined");
        //        }
        //        if CLLocationManager.authorizationStatus() == .authorizedAlways {
        //            print("authorizedAlways");
        //        }
        //        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        //            print("authorizedWhenInUse");
        //        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude
        //            locationManager.stopUpdatingLocation()
        print("lat",lat, "long", long)
        
    }
    
    

}
