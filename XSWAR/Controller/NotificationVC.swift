//
//  NotificationVC\.swift
//  XSWAR
//
//  Created by Tejas Vaghasiya on 05/02/21.
//

import UIKit

class NotiCell : UITableViewCell
{
    @IBOutlet var lblNotification : UILabel!
    @IBOutlet var imgIcon : UIImageView!

    @IBOutlet var btnAccept : UIButton!
    @IBOutlet var btnDecline : UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.layer.shadowOffset = CGSize.init(width: 3.0, height: 3.0)
//        self.layer.shadowColor = UIColor.lightGray.cgColor
//        self.layer.shadowRadius = 3.0
//        self.layer.shadowOpacity = 0.6
//        self.clipsToBounds = false
//        self.layer.zPosition = 10
    }
    
}

class NotificationVC: UIViewController {

    @IBOutlet var btnBack : UIButton!
    @IBOutlet var btnLogout : UIButton!

    @IBOutlet var tblNotification : UITableView!
    var isFromDashboard = Bool()

    var notiList : [NotificationList] = []
    var refreshControl = UIRefreshControl()

    
    override func viewDidDisappear(_ animated: Bool)
    {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblNotification.tableFooterView = UIView()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tblNotification.addSubview(refreshControl) // not required when using UITableViewController
    }
    override func viewWillAppear(_ animated: Bool) {
        tblNotification.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
       
        if isFromDashboard
        {
            let URL_API = BASE_URL.appending(API_GET_NOTIFICATIONS_USER)
            APIParser.dataWithURL(url: URL_API, requestType:.TYPE_GET, bodyObject: [:], imageObject: [], isShowProgress: false, isHideProgress: true) { (response, data) in
                
                self.refreshControl.endRefreshing()

                let notificationData = try! NotificationData.init(data: data)

                if notificationData.success!
                {
                    self.notiList = notificationData.data!
                    self.tblNotification.reloadData()
                }
            }
        }
        else
        {
            let URL_API = BASE_URL.appending(API_GET_NOTIFICATIONS_DEALER)
            APIParser.dataWithURL(url: URL_API, requestType:.TYPE_GET, bodyObject: [:], imageObject: [], isShowProgress: false, isHideProgress: true) { (response, data) in
                
                self.refreshControl.endRefreshing()

                let notificationData = try! NotificationData.init(data: data)

                if notificationData.success!
                {
                    self.notiList = notificationData.data!
                    self.tblNotification.reloadData()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if isFromDashboard
        {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            
            self.btnBack.isHidden = false
            self.btnLogout.isHidden = true
            
            let URL_API = BASE_URL.appending(API_GET_NOTIFICATIONS_USER)
            APIParser.dataWithURL(url: URL_API, requestType:.TYPE_GET, bodyObject: [:], imageObject: [], isShowProgress: true, isHideProgress: true) { (response, data) in
                
                let notificationData = try! NotificationData.init(data: data)

                if notificationData.success!
                {
                    self.notiList = notificationData.data!
                    self.tblNotification.reloadData()
                }
            }
        }
        else
        {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            
            self.btnBack.isHidden = true
            self.btnLogout.isHidden = false

            let URL_API = BASE_URL.appending(API_GET_NOTIFICATIONS_DEALER)
            APIParser.dataWithURL(url: URL_API, requestType:.TYPE_GET, bodyObject: [:], imageObject: [], isShowProgress: true, isHideProgress: true) { (response, data) in
                
                let notificationData = try! NotificationData.init(data: data)

                if notificationData.success!
                {
                    self.notiList = notificationData.data!
                    self.tblNotification.reloadData()
                }
                else
                {
                    self.notiList = []
                    self.tblNotification.reloadData()
                    
                    self.showAlertWithTitle(alertTitle: "", msg: notificationData.message!)
                }
            }
        }
        
    }
    
    @IBAction func btnBackClick(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnlogoutClick(_ sender: UIButton)
    {
        let URL_API = BASE_URL.appending(API_LOGOUT)
        APIParser.dataWithURL(url: URL_API, requestType:.TYPE_GET, bodyObject: [:], imageObject: [], isShowProgress: true, isHideProgress: true) { (response, data) in
            
            appDelegate.userSignUpData = nil
            appDelegate.dealerLoginData = nil
            
            UserDefaults.standard.removeObject(forKey: "UserData")
            UserDefaults.standard.synchronize()
            
            UserDefaults.standard.removeObject(forKey: "DUserData")
            UserDefaults.standard.synchronize()
            
            if #available(iOS 13.0, *) {
                sceneDelegate.setRoot()
            } else {
                appDelegate.setRoot()
            }
        }
    }
}


extension NotificationVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.notiList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let dic = self.notiList[indexPath.row]
        
        var cell = NotiCell()
        
        if isFromDashboard
        {
            if dic.dealerStatus == "Pending"
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "NotiCell", for: indexPath) as! NotiCell
            }
            else if dic.dealerStatus == "Accept"
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "NotiCell1", for: indexPath) as! NotiCell
                cell.imgIcon.image = UIImage.init(named: "ic_yes")
            }
            else if dic.dealerStatus == "Reject"
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "NotiCell1", for: indexPath) as! NotiCell
                cell.imgIcon.image = UIImage.init(named: "ic_no")
            }
            
            
            cell.lblNotification.text = dic.requestText
            
            if dic.isRead == 1
            {
                cell.lblNotification.font = UIFont.init(name: "Liberation Sans", size: 18.0)
            }
            else
            {
                cell.lblNotification.font = UIFont.init(name: "LiberationSans-Bold", size: 18.0)
            }
        }
        else
        {
            if dic.userStatus == "Pending"
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "NotiCell", for: indexPath) as! NotiCell
            }
            else if dic.userStatus == "Accept"
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "NotiCell1", for: indexPath) as! NotiCell
                cell.imgIcon.image = UIImage.init(named: "ic_yes")
            }
            else if dic.userStatus == "Reject"
            {
                cell = tableView.dequeueReusableCell(withIdentifier: "NotiCell1", for: indexPath) as! NotiCell
                cell.imgIcon.image = UIImage.init(named: "ic_no")
            }
            
            cell.applyShadow()

            
            cell.lblNotification.text = dic.requestText
            
            if dic.isRead == 1
            {
                cell.lblNotification.font = UIFont.init(name: "Liberation Sans", size: 18.0)
            }
            else
            {
                cell.lblNotification.font = UIFont.init(name: "LiberationSans-Bold", size: 18.0)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dic = self.notiList[indexPath.row]

        if isFromDashboard
        {
            if dic.isRead == 0
            {
                let URL_API = BASE_URL.appending(API_READ_NOTIFICATION).appending("request_id=\(dic.requestID ?? 0)")
                
                APIParser.dataWithURL(url: URL_API, requestType:.TYPE_GET, bodyObject: [:], imageObject: [], isShowProgress: true, isHideProgress: true) { (response, data) in
                    
                    let notificationDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailsVC") as! NotificationDetailsVC
                    notificationDetailsVC.notificationDic = dic
                    self.navigationController?.pushViewController(notificationDetailsVC, animated: true)
                }
            }
            else
            {
                let notificationDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailsVC") as! NotificationDetailsVC
                notificationDetailsVC.notificationDic = dic
                self.navigationController?.pushViewController(notificationDetailsVC, animated: true)
            }
        }
        else
        {
            if dic.dealerStatus == "Pending"
            {
                if dic.isRead == 0
                {
                    let URL_API = BASE_URL.appending(API_READ_NOTIFICATION).appending("request_id=\(dic.requestID ?? 0))")
                    
                    APIParser.dataWithURL(url: URL_API, requestType:.TYPE_GET, bodyObject: [:], imageObject: [], isShowProgress: true, isHideProgress: true) { (response, data) in
                        
                        let requestHandleVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestHandleVC") as! RequestHandleVC
                        requestHandleVC.selectedNoti = dic
                        requestHandleVC.isFromDashboard = self.isFromDashboard
                        self.navigationController?.pushViewController(requestHandleVC, animated: true)
                    }
                }
                else
                {
                    let requestHandleVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestHandleVC") as! RequestHandleVC
                    requestHandleVC.selectedNoti = dic
                    requestHandleVC.isFromDashboard = self.isFromDashboard
                    self.navigationController?.pushViewController(requestHandleVC, animated: true)
                }
            }
            else
            {
                if dic.isRead == 0
                {
                    let URL_API = BASE_URL.appending(API_READ_NOTIFICATION).appending("request_id=\(dic.requestID ?? 0))")
                    
                    APIParser.dataWithURL(url: URL_API, requestType:.TYPE_GET, bodyObject: [:], imageObject: [], isShowProgress: true, isHideProgress: true) { (response, data) in
                        
                        self.notiList[indexPath.row].isRead = 1
                        self.tblNotification.reloadData()
                    }
                }
            }
        }
    }
}
