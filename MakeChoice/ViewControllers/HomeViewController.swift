//
//  HomeViewController.swift
//  MakeChoice
//
//  Created by 吴梦宇 on 7/9/15.
//  Copyright (c) 2015 ___mengyu wu___. All rights reserved.
//

import UIKit
import ConvenienceKit

class HomeViewController: UIViewController,TimelineComponentTarget {
    
    @IBOutlet weak var tableView: UITableView!
    
    // implement timelineComponentTarget
    // angled brackets: the type of object you are displaying (Post) and the class that will be the target of the TimelineComponent (that's the TimelineViewController in our case).
    var timelineComponent:TimelineComponent<Post, HomeViewController>!
   
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
    
    /**
    This method should load the items within the specified range and call the
    `completionBlock`, with the items as argument, upon completion.
    */
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void){
        ParseHelper.timelineRequestforCurrentUserPublic(range){ (result: [AnyObject]?, error: NSError?) -> Void in
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

}

// MARK: tableview delegate and datasource
extension HomeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //loadmore if (indexPath.section == (currentRange.endIndex - 1) && !loadedAllContent)
       // println("willDisplayCell: \(indexPath.section) \(timelineComponent.content[indexPath.section].totalVotes)")
        timelineComponent.calledCellForRowAtIndexPath(indexPath)
    }

}
extension HomeViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier("PostHeader") as! HomePostSectionHeaderView
        let post=self.timelineComponent.content[section]
        headerCell.post=post
        //let the header show up when updated
        return headerCell.contentView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return timelineComponent.content.count ?? 0
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell=tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! HomePostTableViewCell
        
        let post=timelineComponent.content[indexPath.section]
        
       // println("cellforRowat index.section: \(indexPath.section) post.totalValue: \(post.totalVotes) ")
        
        // download, only downloaded with needed
        post.downloadImage()
        //get post statistic
        post.getPostStatistic()
        
        
        cell.post=post
        
        //setting background color and radious
        cell.img1.backgroundColor=UIColor.redColor()
        cell.img1.layer.cornerRadius=8
        cell.img1.clipsToBounds=true
        
        cell.img2.backgroundColor=UIColor.blueColor()
        cell.img2.layer.cornerRadius=8
        cell.img2.clipsToBounds=true
        
        
        cell.img1.userInteractionEnabled=true
        cell.img1.tag=indexPath.section
        
        cell.img2.userInteractionEnabled=true
        cell.img2.tag=indexPath.section
        
        var img1tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("img1Tapped:" ))
        cell.img1.addGestureRecognizer(img1tapped)
        
        var img2tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("img2Tapped:" ))
        cell.img2.addGestureRecognizer(img2tapped)
        
        //check if this sell is voted by this user, if voted, show the results
    
        var postId=post.objectId
        
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

        }
        
       
        return cell
    }
    
    func img1Tapped(recognizer:UITapGestureRecognizer ){
        
        println("the \(recognizer.view?.tag)th  posts: img1 tapped")
        
        if let tag=recognizer.view?.tag{
           var postId=timelineComponent.content[tag].objectId
            
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
                                        println("totalVote\(self.timelineComponent.content[tag].totalVotes)")
                                        
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
            var postId=timelineComponent.content[tag].objectId
            
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

