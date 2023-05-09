//
//  LoginViewController.swift
//  Smartech Demo
//
//  Created by Ramakrishna Kasuba on 25/09/21.
//

import UIKit
import FirebaseAuth
import SmartechAppInbox
import Smartech


class DashboardViewController: UIViewController {
    
    var VC:ViewController!
    var notifVC:NotificationVC!
    
    @IBOutlet weak var logoutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 //       Smartech.sharedInstance().trackEvent("screen_viewed", andPayload: ["current page":"Profile page"])
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func logoutUser(_ sender: UIButton) {
        removeCurrentUser()
        
        Smartech.sharedInstance().trackEvent("Logout_success", andPayload: nil)
        Smartech.sharedInstance().logoutAndClearUserIdentity(true)
        self.dismiss(animated: true)
        
    }
    
        func removeCurrentUser(){
            if UserDefaults.standard.value(forKey: "userLogged") != nil {
                UserDefaults.standard.removeObject(forKey: "userLogged")
                UserDefaults.standard.synchronize()
            }
        }
    
}
