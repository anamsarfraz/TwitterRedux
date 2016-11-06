//
//  MenuViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 11/3/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    
    private var tweetsNavigationController: UIViewController!
    private var mentionsNavigationController: UIViewController!
    private var profileNavigationController: UIViewController!
    
    var viewControllers: [UIViewController] = []
    var vcTitles: [String] = []
    weak var hamburgerViewController: HamburgerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        print ("Coming in menu view controller viewDidoad")

        tableView.dataSource = self
        tableView.delegate = self
        
        let profileImageUrl = User.currentUser?.profileUrl
        if let profileImageUrl = profileImageUrl {
            profileImageView.setImageWith(profileImageUrl)
        }
        userNameLabel.text = (User.currentUser?.name)!
        taglineLabel.text = (User.currentUser?.tagline)!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        tweetsNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        let tweetsVC = (tweetsNavigationController as! UINavigationController).visibleViewController as! TweetsViewController
        tweetsVC.timeline = "home"
        viewControllers.append(tweetsNavigationController)
        vcTitles.append("Home Timeline")

        mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "MentionsNavigationController")
        let menuVC = (mentionsNavigationController as! UINavigationController).visibleViewController as! TweetsViewController
        menuVC.timeline = "mentions"
        viewControllers.append(mentionsNavigationController)
        vcTitles.append("Mentions")
        
        profileNavigationController = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController")
        let profileVC = (profileNavigationController as! UINavigationController).visibleViewController as! ProfileViewController
        profileVC.timeline = "user"
        profileVC.user = User.currentUser
        viewControllers.append(profileNavigationController)
        vcTitles.append("Profile")
        
        hamburgerViewController?.contentViewController = tweetsNavigationController
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vcTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        menuCell.menuTitleLabel.text = vcTitles[indexPath.row]
        
        return menuCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hamburgerViewController?.contentViewController = viewControllers[indexPath.row]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let numCells = Float(vcTitles.count)
        let tableHeight = Float(tableView.frame.size.height)
        return CGFloat(tableHeight / numCells)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
