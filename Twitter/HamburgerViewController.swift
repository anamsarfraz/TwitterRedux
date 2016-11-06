//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 11/3/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    var originalLeftMargin: CGFloat!
    var menuViewController: MenuViewController! {
        didSet {
            view.layoutIfNeeded()
            menuView.addSubview(menuViewController.view)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            print ("Coming in didSet")
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
                
            }
            
            contentViewController.willMove(toParentViewController: self)
            
            contentView.addSubview(contentViewController.view)
            
            contentViewController.didMove(toParentViewController: self)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        print ("Coming in hamburger view controller viewDidLoad")

        if menuViewController == nil {
            print ("Menu view controller is not set")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            menuViewController.hamburgerViewController = self
            self.menuViewController = menuViewController

        }
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        switch (sender.state) {
        case .began:
            originalLeftMargin = leftMarginConstraint.constant
        case .changed:
            leftMarginConstraint.constant = originalLeftMargin + translation.x
        case .ended:
            UIView.animate(withDuration: 0.3, animations: {
                self.leftMarginConstraint.constant = velocity.x > 0 ? self.view.frame.size.width - 50 : 0
                self.view.layoutIfNeeded()
            })
            
        default:
            break
        }
        
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
