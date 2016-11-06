//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/26/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetComposeViewControllerDelegate, UIScrollViewDelegate, TweetCellDelegate {
    
    var tweets: [Tweet]!
    var currTweets: [Tweet]!

    @IBOutlet weak var tableView: UITableView!
    
    var currOffSet = ""
    var currTotal = maxTweetLimit
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    let refreshControl = UIRefreshControl()
    var timeline: String!
    
    
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

        // Set navigation bar colors
        navigationController?.navigationBar.barTintColor = twitterBlue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false

        // Create a UIRefreshControl instance and add it to tweets table view
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets

        // Refresh the timeline
        refresh(refreshControl: refreshControl)
    }

    func refresh(refreshControl: UIRefreshControl) {
        if (!isMoreDataLoading) {
            // Set the current offset to zero if there is no infinite scroll
            currOffSet = ""
        }

        var parameters: [String : AnyObject] = ["count": "20" as AnyObject]
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
            print ("Total tweets count after home timeline call: \(self.tweets.count)")
            self.tableView.reloadData()
            refreshControl.endRefreshing()
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
        } else {
            print ("Coming here in presenting Profile")
            let profileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as! ProfileViewController
            profileVC.user = tweetCell.tweet.user
            profileVC.timeline = "user"
            //navigationController?.pushViewController(profileVC, animated: true)
            show(profileVC, sender: self)
            
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweetCell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        tweetCell.tweet = tweets?[indexPath.row]
        tweetCell.replyButton.tag = indexPath.row
        tweetCell.delegate = self
        return tweetCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "TweetDetailViewController") as! TweetDetailViewController
        detailViewController.tweet = tweets?[indexPath.row]
        show(detailViewController, sender: self)

    }

    func tweetComposeViewController(tweetComposeViewController: TweetComposeViewController, didCreateTweetOrReply data: NSDictionary) {
        let newTweet = Tweet(dictionary: data)
        if tweets == nil {
            tweets = [Tweet]()
        }
        tweets?.insert(newTweet, at: 0)
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
                    refresh(refreshControl: refreshControl)
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
            tweetComposeVC.delegate = self
            
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
