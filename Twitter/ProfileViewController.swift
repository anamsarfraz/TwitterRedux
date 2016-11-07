//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 11/5/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TweetCellDelegate {
    
    var tweets: [Tweet]!
    var currTweets: [Tweet]!
    var currProfile: UserProfile!
    var timeline: String!
    var scrollViewHeight: NSLayoutConstraint?
    var origScrollViewHeight: CGFloat?
    var profileCell: ProfileCell?
    var blurEffectView: UIVisualEffectView?
    
    @IBOutlet weak var tableView: UITableView!
    
    var currOffSet = ""
    var currTotal = maxTweetLimit
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var user: User?
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize empty arrays for tweets results
        tweets = [Tweet]()
        currTweets = [Tweet]()
        
        // Initialize tweets table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.register(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")
        tableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")

        // Initialize title
        
        // Set navigation bar colors
        navigationController?.navigationBar.barTintColor = twitterBlue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationItem.title = user?.name ?? ""
        navigationController?.navigationBar.isTranslucent = false
        
        // Add gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        
        //longPress.delegate = self
        navigationController?.navigationBar.addGestureRecognizer(longPress)
        
        // Create a UIRefreshControl instance and add it to tweets table view
        
        refreshControl.addTarget(self, action: #selector(refreshUserTimeline), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets

        // Load user profile
        self.loadUserProfile()

        // Refresh the user timeline
        refreshUserTimeline(refreshControl: refreshControl)
    }
    
    func loadUserProfile() {
        
        let parameters: [String : AnyObject] = ["screen_name": (user?.screenname)! as AnyObject]

        TwitterClient.sharedInstance.userProfile(params: parameters as NSDictionary) { (profile, error) in
            self.currProfile = profile
            self.tableView.reloadData()
        }
    }
    
    func refreshUserTimeline(refreshControl: UIRefreshControl) {
        if (!isMoreDataLoading) {
            // Set the current offset to zero if there is no infinite scroll
            currOffSet = ""
        }
        
        var parameters: [String : AnyObject] = ["count": "20" as AnyObject]
        parameters["screen_name"] = (user?.screenname)! as AnyObject
        if currOffSet != "" {
            parameters["max_id"] = currOffSet as AnyObject
        }
        TwitterClient.sharedInstance.timeline(timeline: timeline, params: parameters as NSDictionary) { (tweets, minId, error) in
            
            self.currTweets = tweets
            
            // Check if more data is loading, stop infinite scroll animation
            if (self.isMoreDataLoading) {
                self.loadingMoreView?.stopAnimating()
                self.isMoreDataLoading = false
                self.tweets.append(contentsOf: self.currTweets ?? [])
            } else {
                self.tweets = self.currTweets
            }
            
            if let minId = minId {
                self.currOffSet = minId
            }
            print ("Total tweets count after user timeline call: \(self.tweets.count)")
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    func onLongPress(sender: UILongPressGestureRecognizer) {
        print ("Long Press Happened")
        
        if sender.state == .ended {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let accountsViewController = storyboard.instantiateViewController(withIdentifier: "AccountsViewController") as! AccountsViewController
            show(accountsViewController, sender: self)

        }

    }
    
    func tweetCell(tweetCell: TweetCell, sender: AnyObject) {
        print ("Delegate method called")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if  ((sender as? UIButton) != nil) {
            let tweetComposeNC = storyboard.instantiateViewController(withIdentifier: "TweetComposeNavigationController") as! UINavigationController
            let tweetComposeVC = tweetComposeNC.topViewController as! TweetComposeViewController
            tweetComposeVC.user = User._currentUser
            
            let tweet = tweetCell.tweet!
            tweetComposeVC.replyTo = tweet.tweetId
            tweetComposeVC.replyToScreenName = ""
            if let retweetedStatus = tweet.retweetedStatus {
                tweetComposeVC.replyToScreenName += "@\((retweetedStatus.user?.screenname)!) "
            }
            tweetComposeVC.replyToScreenName += "@\((tweet.user?.screenname)!) "
            self.present(tweetComposeNC, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            if let currProfile = currProfile {
                profileCell.userProfile = currProfile
                
            }
            scrollViewHeight = profileCell.scrollViewHeight
            if origScrollViewHeight != nil {
                profileCell.scrollViewHeight.constant = origScrollViewHeight!
            } else {
                origScrollViewHeight = scrollViewHeight?.constant

            }
            self.profileCell = profileCell
            
            print ("Profile cell Height: \(origScrollViewHeight)")
            return profileCell
            
        } else {
            let tweetCell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
            tweetCell.tweet = tweets?[indexPath.row]
            tweetCell.replyButton.tag = indexPath.row
            tweetCell.delegate = self
            return tweetCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
        if indexPath.section == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailViewController = storyboard.instantiateViewController(withIdentifier: "TweetDetailViewController") as! TweetDetailViewController
            detailViewController.tweet = tweets?[indexPath.row]
            show(detailViewController, sender: self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print ("In profile scroll: \(scrollView.contentOffset.y)")

        let y: CGFloat = -scrollView.contentOffset.y
        
        if (y >= 0) {
            let blurEffect: UIBlurEffect = UIBlurEffect(style: y > origScrollViewHeight! ? .extraLight : .regular)

            if (blurEffectView == nil) {
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView?.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleHeight.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
                blurEffectView?.frame = (profileCell?.bannerImageView.bounds)!
                
            } else {
                blurEffectView?.effect = blurEffect
            }
            scrollViewHeight?.constant = origScrollViewHeight! + y
            profileCell?.layoutIfNeeded()
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
        if y > 0 {
            profileCell?.bannerImageView.addSubview(blurEffectView!)
        } else {
            blurEffectView?.removeFromSuperview()
        }
        
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                
                print ("Total tweets count in inifinite scroll: \(tweets.count)")
                if tweets.count < currTotal {
                    currOffSet = (tweets.last?.tweetId)!
                    loadingMoreView!.startAnimating()
                    refreshUserTimeline(refreshControl: refreshControl)
                }
            }
        }
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            let tweetComposeVC = navigationController.topViewController as! TweetComposeViewController
            tweetComposeVC.user = User._currentUser
            
            if let replyButton = sender as? UIButton {
                print ("sender is the reply Button")
                let tweet = (tweets?[replyButton.tag])!
                tweetComposeVC.replyTo = tweet.tweetId
                tweetComposeVC.replyToScreenName = ""
                if let retweetedStatus = tweet.retweetedStatus {
                    tweetComposeVC.replyToScreenName += "@\((retweetedStatus.user?.screenname)!) "
                }
                tweetComposeVC.replyToScreenName += "@\((tweet.user?.screenname)!) "
                
            }
            
        } else {
            let tweetCell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: tweetCell)!
            
            let detailViewController = segue.destination as! TweetDetailViewController
            detailViewController.tweet = tweets?[indexPath.row]
        }
        
    }
}
