//
//  CategoryDetailViewController.swift
//  MakeChoice
//
//  Created by 吴梦宇 on 7/20/15.
//  Copyright (c) 2015 ___mengyu wu___. All rights reserved.
//

import UIKit
import ConvenienceKit
class CategoryDetailViewController: UIViewController,TimelineComponentTarget {

    
    @IBOutlet weak var tableView: UITableView!
    
    // implement timelineComponentTarget
    // angled brackets: the type of object you are displaying (Post) and the class that will be the target of the TimelineComponent (that's the TimelineViewController in our case).
    var timelineComponent:TimelineComponent<Post, CategoryDetailViewController>!
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    var categoryIndex:Int?
    
    var user:PFUser?
    
 
    /**
    This method should load the items within the specified range and call the
    `completionBlock`, with the items as argument, upon completion.
    */
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void){
        println("index: \(categoryIndex!)")
        ParseHelper.timelineRequestforCurrentUserWithCategory(range,categoryIndex:categoryIndex!){ (result: [AnyObject]?, error: NSError?) -> Void in
            let posts = result as? [Post] ?? []
            completionBlock(posts)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate=self
        self.tableView.dataSource=self
        timelineComponent = TimelineComponent(target: self)
        
        //assign the installation[user] to be current user
        PushNotication.parsePushUserAssign()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timelineComponent.refresh(self)
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if( segue.identifier=="commentPushSegue"){
            let commentVC = segue.destinationViewController as! CommentViewController
            commentVC.hidesBottomBarWhenPushed = true
            
            if let post=sender as? Post{
                let groupId = post.objectId! as String ?? ""
                commentVC.groupId = groupId
                commentVC.post=post
            }
            
            
        }
    }
    
    
}

// MARK: tableview delegate and datasource
extension CategoryDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
     
        
        timelineComponent.calledCellForRowAtIndexPath(indexPath)
        
    }
    
}
extension CategoryDetailViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("CategoryDetailHeader") as! CategoryDetailHeaderTableViewCell
        var post:Post?
        post=self.timelineComponent.content[section]
        
        headerCell.post=post
        //let the header show up when updated
        return headerCell.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_CELL_HEIGHT
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var num=0
        num=timelineComponent.content.count ?? 0
        return num
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell=tableView.dequeueReusableCellWithIdentifier("CategoryDetailCell", forIndexPath: indexPath) as! CategoryDetailTableViewCell
        
        var post:Post?
        
        post=timelineComponent.content[indexPath.section]
              // download, only downloaded with needed
        if let post=post {
            post.downloadImage()
            //get post statistic
            post.getPostStatistic()
        }
        
        cell.post=post
        
        //setting img radious
        DesignHelper.setImageCornerRadius(cell.img1)
        DesignHelper.setImageCornerRadius(cell.img2)
        
        
        
        // establish gestureRecognizer
        cell.img1.userInteractionEnabled=true
        cell.img1.tag=indexPath.section
        
        cell.img2.userInteractionEnabled=true
        cell.img2.tag=indexPath.section
        
        var img1tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("img1Tapped:" ))
        cell.img1.addGestureRecognizer(img1tapped)
        
        var img2tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("img2Tapped:" ))
        cell.img2.addGestureRecognizer(img2tapped)
        
        
        // commentButton:
        cell.commentButton.tag=indexPath.section
        
        cell.commentButton.addTarget(self, action: Selector("commentButtonTapped:" ), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.commentNum.text="" //initialize the comment number
        
        
        //check if this sell is voted by this user, if voted, show the results
        
        var postId=post?.objectId
        
        if let postId=postId{
            ParseHelper.isUserVotedForPost(postId){ (results: [AnyObject]?, error: NSError?) -> Void in
                
                if let count=results?.count{
                    if count != 0{
                        
                        // if is voted show the results
                        cell.vote1.alpha=1;
                        cell.vote2.alpha=1;
                    }else{
                        cell.vote1.alpha=0;
                        cell.vote2.alpha=0;
                    }
                }
                
            }
            
            
            
            // get comment number
            ParseHelper.getCommentNumberWithPostId(postId){ (results: [AnyObject]?, error:NSError?) -> Void in
                if let results=results{
                    cell.commentNum.text=(results.count == 0) ? "": String(results.count)
                    
                    
                }
                
            }
            
            
        }
        
        
        return cell
    }
    
    
    func commentButtonTapped(sender:UIButton!){
        
        
        var postId:String?
        var post:Post?
        var tag=sender.tag
        postId=timelineComponent.content[tag].objectId
        post=timelineComponent.content[tag]
        
        if let postId=postId{
            self.performSegueWithIdentifier("commentPushSegue", sender: post)
        }
        
    }
    
    func img1Tapped(recognizer:UITapGestureRecognizer ){
        
        println("the \(recognizer.view?.tag)th  posts: img1 tapped")
        
        if let tag=recognizer.view?.tag{
            var postId:String?
            var poster:PFUser?
            
            postId=timelineComponent.content[tag].objectId
            poster=timelineComponent.content[tag].poster
            
            if let postId=postId{
                println("postId:\(postId)")
                
                ParseHelper.isUserVotedForPost(postId){ (results:[AnyObject]?, error:NSError?) -> Void in
                    if let results=results as? [PFObject]{
                        
                        if(results.count != 0){
                            println("voted!")
                            // alreday voted!
                            // show results:
                        }else{
                            println("save new vote")
                            // save the result, and show results
                            ParseHelper.saveVote(postId, choice: 1)
                            
                            //update this post statistics
                            ParseHelper.updatePostStatistic(postId, choice: 1){ (success:Bool,error:NSError?) -> Void in
                                
                                if success {
                                    println("success upadatePostStatistic")
                                    //update post statistic
                                    
                                    //update the content
                                    ParseHelper.findPostWithPostId(postId){ (results:[AnyObject]?, error:NSError?) -> Void in
                                        
                                        if let results=results as? [Post]{
                                            
                                            self.timelineComponent.content[tag]=results.first!
                                            println("totalVote\(self.timelineComponent.content[tag].totalVotes)")                                       //send notification if the voter is not poster
                                            if let poster=poster{
                                                if (poster.objectId != PFUser.currentUser()?.objectId){
                                                    PushNotificationHelper.sendVoteNotification(poster)
                                                }
                                                
                                            }
                                            
                                            self.tableView.beginUpdates()
                                            self.tableView.reloadSections(NSIndexSet(index:tag),withRowAnimation: UITableViewRowAnimation.Automatic)
                                            self.tableView.endUpdates()
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                            
                            
                        }
                    }
                    
                    if error != nil {
                        println(error)
                    }
                    
                }
            }
        }
        
    }
    
    
    func img2Tapped(recognizer:UITapGestureRecognizer ){
        
        println("the \(recognizer.view?.tag)th  posts: img2 tapped")
        
        if let tag=recognizer.view?.tag{
            var postId:String?
            var poster:PFUser?
            postId=timelineComponent.content[tag].objectId
            poster=timelineComponent.content[tag].poster
            
            if let postId=postId{
                println("postId:\(postId)")
                
                ParseHelper.isUserVotedForPost(postId){ (results:[AnyObject]?, error:NSError?) -> Void in
                    if let results=results as? [PFObject]{
                        
                        if(results.count != 0){
                            println("voted!")
                            // alreday voted!
                            // show results:
                        }else{
                            println("save new vote")
                            // save the result, and show results
                            ParseHelper.saveVote(postId, choice: 2)
                            
                            //update this post statistics
                            ParseHelper.updatePostStatistic(postId, choice:2){ (success:Bool,error:NSError?) -> Void in
                                
                                if success {
                                    println("success upadatePostStatistic")
                                    //update post statistic
                                    
                                    //update the content
                                    ParseHelper.findPostWithPostId(postId){ (results:[AnyObject]?, error:NSError?) -> Void in
                                        
                                        if let results=results as? [Post]{
                                            self.timelineComponent.content[tag]=results.first!
                                            println("totalVote\(self.timelineComponent.content[tag].totalVotes)")
                                            //send notification if the voter is not poster
                                            if let poster=poster{
                                                if (poster.objectId != PFUser.currentUser()?.objectId){
                                                    PushNotificationHelper.sendVoteNotification(poster)
                                                }
                                                
                                            }
                                            
                                            
                                            self.tableView.beginUpdates()
                                            self.tableView.reloadSections(NSIndexSet(index:tag),withRowAnimation: UITableViewRowAnimation.Automatic)
                                            self.tableView.endUpdates()
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    
                    if error != nil {
                        println(error)
                    }
                    
                }
            }
        }
        
    }
    
    
    
    
    
    
}
