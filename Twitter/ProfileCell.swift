//
//  ProfileCell.swift
//  Twitter
//
//  Created by Unum Sarfraz on 11/5/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet weak var bannerImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screennameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var follwersCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    @IBOutlet weak var page1: UIView!
    @IBOutlet weak var page2: UIView!

    var userProfile: UserProfile! {
        didSet {
            setProfileCellView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true

        configurePageControl()
    }

    func configurePageControl() {
        scrollView.delegate = self
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.green
    }
    
    @IBAction func pageChange(_ sender: AnyObject) {
        bannerImageView.alpha = pageControl.currentPage == 1 ? 1.0: 0.5
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        bannerImageView.alpha = pageControl.currentPage == 1 ? 1.0: 0.5
    }
    
    func setProfileCellView() {
        if let bannerUrl = userProfile.profileBannerUrl {
            bannerImageView.setImageWith(bannerUrl)
            //bannerImageView.alpha = 0.5
        }

        if let profileUrl = userProfile.profileUrl {
            profileImageView.setImageWith(profileUrl)
        }
        screennameLabel.text = "@\((userProfile.screenname)!)"
        usernameLabel.text = (userProfile.name)!
        taglineLabel.text = (userProfile.tagline)!
        
        tweetsCountLabel.text = abbreviateNumber(number: userProfile.tweets)
        follwersCountLabel.text = abbreviateNumber(number: userProfile.followers)
        followingCountLabel.text = abbreviateNumber(number: userProfile.following)

    }
    
    func formatNumber(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number))!
    }
    
    func abbreviateNumber(number: Int) -> String {
        
        var abbrevNum: String = ""
        var doubleNum: Double = Double(number)
        
        let units = [("T", 1000000000000), ("B", 1000000000), ("M", 1000000), ("K", 1000)];
        if (number >= 10000) {
            
            
            for (unit, mul) in units {
            
                if mul <= number {
                    doubleNum = Double(number)/Double(mul)
                    abbrevNum = "\(String(format: "%.1f", doubleNum))\(unit)"
                    break
                    
                }
                
            }
        } else {
            
            abbrevNum = formatNumber(number: number)
        }
        
        return abbrevNum;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
