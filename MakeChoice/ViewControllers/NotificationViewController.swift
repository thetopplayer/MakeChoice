//
//  NotificationViewController.swift
//  MakeChoice
//
//  Created by 吴梦宇 on 7/23/15.
//  Copyright (c) 2015 ___mengyu wu___. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifications:[PFObject]=[]{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.dataSource=self
        self.tableView.delegate=self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ParseHelper.getAllNotificationsOfCurrentUser{ (results:[AnyObject]?, error:NSError?) -> Void in
            
            if let results=results as? [PFObject]{
                self.notifications=results
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK:datasource

extension NotificationViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell=tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! NotificationTableViewCell
        cell.notification=notifications[indexPath.row]
        
        return cell
        
    }

}

// MARK: tableView cell deleate
extension NotificationViewController:UITableViewDelegate{
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if( segue.identifier=="notificationTodetailSegue" ){
            let postDetailViewController = segue.destinationViewController as! PostDetailViewController
            var post=sender as! Post
            postDetailViewController.post=post
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        var notification=notifications[indexPath.row]
        var post=notification[PF_NOTIFICATION_POST] as? Post
        
        if let post=post{
          //only download the image if needed
          post.downloadImageSynchronous()
          self.performSegueWithIdentifier("notificationTodetailSegue", sender: post)
        }
     
    }
}
