//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Robert on 8/5/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewControllerTwo: UITableViewController {
    
    var usernames = [""]
    var userids = [""]
    var isFollowing = ["":false]
    var refresher: UIRefreshControl!
    
    func refresh() {
        
        var query = PFUser.query()
        
        //Query the PFUsers and store the info in objects (as an anyObject)
        query?.findObjectsInBackgroundWithBlock({ (objects,error) in
            
            if let users = objects { //if objects != nil
                
                self.usernames.removeAll(keepCapacity: true)//clear array
                self.userids.removeAll(keepCapacity: true)//clear array
                self.isFollowing.removeAll(keepCapacity: true)//clear array
                
                for object in users { //cycle through each user
                    
                    if let user = object as? PFUser { //checks for valid user then casts to PFUser
                        
                        if user.objectId != PFUser.currentUser()?.objectId { //doesn't print current user to User List
                            
                            self.usernames.append(user.username!) //adds the users name to the usernames array
                            self.userids.append(user.objectId!) //adds the users ID to the userids array
                            
                            /***********Check for following**********************/
                            var query = PFQuery(className: "followers")
                            
                            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!) //current user
                            query.whereKey("following", equalTo: user.objectId!) //user we are looping through
                            
                            //run the query
                            query.findObjectsInBackgroundWithBlock({ (objects, error) in
                                
                                if let objects = objects {
                                    
                                    if objects.count > 0 { //added to keep everything from being checkmarked
                                        
                                        self.isFollowing[user.objectId!] = true//tells it to checkmark this user
                                        
                                        
                                    } else {
                                        
                                        self.isFollowing[user.objectId!] = false//tells it to uncheckmark user
                                    }
                                }
                                
                                if self.isFollowing.count == self.usernames.count { //checks to make sure it only updates
                                    
                                    self.tableView.reloadData()
                                    self.refresher.endRefreshing()//ends the Pull to Refresh wait symbol and text when you let go
                                    
                                }
                            })
                        }
                    }
                }
            }
            self.usernames = self.usernames.sort()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")//Prints this at the top of the screen when pull to refreshing
        
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged) //runs refresh func when pulled
        
        self.tableView.addSubview(refresher)//adds the subview for pull to refresh
        
        refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return usernames.count //amount of users on Parse
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = usernames[indexPath.row]
        
        let followedObjectId = userids[indexPath.row] //userid of tapped on user
        
        if isFollowing[followedObjectId] == true { //is user following that user
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark //Adds a checkmark to the cell
            
        }
        
        return cell
    }
    
    //When cell is clicked
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)! //assigns the clicked on cell to the variable cell
        let followedObjectId = userids[indexPath.row] //userid of tapped on user
        
        if isFollowing[followedObjectId] == false { //if they aren't currently followed
            
            isFollowing[followedObjectId] = true //make them followed
            
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark //Adds a checkmark to the cell
            
            let following = PFObject(className: "followers") //adds parse followers to following
            following["following"] = userids[indexPath.row] //assigns the clicked on cell's UserID to following
            following["follower"] = PFUser.currentUser()?.objectId //assigns the current users UserID to follower
            
            following.saveInBackground() //saves it back to parse
        } else {
            
            isFollowing[followedObjectId] = false //make them unfollowed
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            /***********Check for following**********************/
            var query = PFQuery(className: "followers")
            
            query.whereKey("follower", equalTo: (PFUser.currentUser()?.objectId)!) //current user
            query.whereKey("following", equalTo: userids[indexPath.row]) //ID of the user that's just been tapped on
            
            //run the query
            query.findObjectsInBackgroundWithBlock({ (objects, error) in
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        object.deleteInBackground()
                        
                    }
                }
                
            })
            
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
