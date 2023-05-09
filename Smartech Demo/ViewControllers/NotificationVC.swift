//
//  NotificationVC.swift
//  Smartech Demo
//
//  Created by Apple on 11/04/22.
//

import UIKit
import SmartechAppInbox

class NotificationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appInboxArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AppInboxCell = tableView.dequeueReusableCell(withIdentifier: "AppInboxCell", for: indexPath) as! AppInboxCell
//        cell.model() = appInboxArray?[indexPath.row] ?? SMTAppInboxMessage()
//        cell.configure()
        return cell
    }
    
    
    let notificationTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    var appInboxArray: [SMTAppInboxMessage]?
    var appInboxCategoryArray: [SMTAppInboxCategoryModel]?
    var pullControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 200, height: 60))
         button.setTitle("Back", for: .normal)
         button.backgroundColor = .white
         button.setTitleColor(UIColor.black, for: .normal)
     //    button.addTarget(self, action: #selector(self.dismissSelf()), for: .touchUpInside)
         view.addSubview(button)

        
        self.navigationItem.title = "Notifications"
        self.view.backgroundColor = .white
        self.view.addSubview(notificationTableView)
        setupPullToRefresh()
        notificationTableView.register(UINib(nibName: "AppInboxCell", bundle: nil), forCellReuseIdentifier: "AppInboxCell")

        setupUI()
        
//        self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "Back"), action: #selector(self.dismissSelf),color: UIColor.white)
       
        appInboxCategoryArray = []
        
        let category = SMTAppInboxCategoryModel()
        category.categoryName = SMTAppInboxCategoryModel.description()
        category.isSelected = true
        appInboxCategoryArray?.append(category)
        fetchDataFromNetcore()
    }
    func setupPullToRefresh(){
        pullControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullControl.addTarget(self, action: #selector(pulledRefreshControl), for: UIControl.Event.valueChanged)
        notificationTableView.addSubview(pullControl) // not required
    }
    
    @objc func pulledRefreshControl(sender:AnyObject) {
        
        SmartechAppInbox.sharedInstance().getMessage(SmartechAppInbox.sharedInstance().getPullToRefreshParameter()) { [] error, status in
            if (status) {
                // Refresh your data
                self.fetchDataFromNetcore()
                self.refreshViews()
            }else{
                DispatchQueue.main.async{
                    self.pullControl.endRefreshing()
                }
            }
        }
    }
    func refreshViews(){
        DispatchQueue.main.async {
            self.pullControl.endRefreshing()
            self.notificationTableView.contentOffset = CGPoint.zero
        }
    }
    
    func setupUI()  {
        [notificationTableView.topAnchor.constraint(equalTo:self.view.topAnchor,constant: 0),
         notificationTableView.leadingAnchor.constraint(equalTo:self.view.leadingAnchor, constant: 0),
         notificationTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
         notificationTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant:0)].forEach{$0.isActive =  true}
    }
    
    func fetchDataFromNetcore() {
        appInboxArray = []
        appInboxCategoryArray = SmartechAppInbox.sharedInstance().getCategoryList()
        appInboxArray = SmartechAppInbox.sharedInstance().getMessageWithCategory(appInboxCategoryArray as? NSMutableArray)
        DispatchQueue.main.async {
            self.notificationTableView.reloadData()
        }

    }
    
    @objc func dismissSelf(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

class AppInboxCell:UITableViewCell {
    
}
