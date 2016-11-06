//
//  UserProfile.swift
//  Twitter
//
//  Created by Unum Sarfraz on 11/5/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class UserProfile: NSObject {
    //
    //  User.swift
    //  Twitter
    //
    //  Created by Unum Sarfraz on 10/26/16.
    //  Copyright © 2016 CodePath. All rights reserved.
    //
        var name: String?
        var screenname: String?
        var profileUrl: URL?
        var profileBannerUrl: URL?
        var tagline: String?
        var followers: Int = 0
        var following: Int = 0
        var tweets: Int = 0
    
        init(dictionary: NSDictionary) {
            name = dictionary[userName] as? String
            screenname = dictionary[userScreenName] as? String
            let profileUrlString = dictionary[profileImageUrlHttps] as? String
            if let profileUrlString = profileUrlString {
                profileUrl = URL(string: profileUrlString)
            }
            let profileBannerUrlString = dictionary[profileBannerUrlHttps] as? String
            if let profileBannerUrlString = profileBannerUrlString {
                profileBannerUrl = URL(string: profileBannerUrlString)
            }

            tagline = dictionary[userDescription] as? String
            
            tweets = (dictionary[tweetCount] as? Int) ?? 0
            followers = (dictionary[followersCount] as? Int) ?? 0
            following = (dictionary[followingCount] as? Int) ?? 0
        }
        


}
