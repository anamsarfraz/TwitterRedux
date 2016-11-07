//
//  AccountCell.swift
//  Twitter
//
//  Created by Unum Sarfraz on 11/6/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    var user: User! {
        didSet {
            setCellView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true

    }

    func setCellView() {
        if let profileUrl = user.profileUrl {
            profileImageView.setImageWith(profileUrl)
        }
        screenNameLabel.text = "@\((user.screenname)!)"
        userNameLabel.text = (user.name)!

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
