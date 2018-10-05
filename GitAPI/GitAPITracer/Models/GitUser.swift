//
//  GitUser.swift
//  GitAPITracer
//
//  Created by Sunil Chauhan on 29/06/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import Foundation

//TODO: Use Codable protocol instead.

/// Class responsible to represent Git User.
public struct GitUser: Equatable, Codable {
    public var gitId: Int = 0
    public var login: String = ""
    public var email: String?
    public var name: String = ""
    public var htmlUrl: String = ""

    public var location: String = ""
    public var company: String = ""
    public var blog: String = ""
    public var hireable: Bool = false
    public var bio: String = ""

    init(json: [String: AnyObject]) {
        if let login = json["login"] as? String {
            self.login = login
        }
        if let gitId = json["id"] as? Int {
            self.gitId = gitId
        }
        if let url = json["html_url"] as? String {
            self.htmlUrl = url
        }
        if let name = json["name"] as? String {
            self.name = name
        }
        if let company = json["company"] as? String {
            self.company = company.replacingOccurrences(of: ",", with: " ")
        }
        if let location = json["location"] as? String {
            self.location = location.replacingOccurrences(of: ",", with: "-")
        }
        if let email = json["email"] as? String {
            self.email = email
        }
        if let blog = json["blog"] as? String {
            self.blog = blog
        }
    }

    public static func == (lhs: GitUser, rhs: GitUser) -> Bool {
        return lhs.gitId == rhs.gitId
    }

    public var csvLineString: String {
        return "\(name), \(login), \(location), \(company), \(email), \(blog), \(htmlUrl)\n"
    }

    private enum CodingKeys: String, CodingKey {
        case gitId = "id"
        case login
        case email
        case name
        case htmlUrl = "html_url"
        case location
        case company
        case blog
        case hireable
        case bio
    }
}

public extension GitUser {

}
/*
 {
 "login": "chauhan130",
 "id": 1622768,
 "node_id": "MDQ6VXNlcjE2MjI3Njg=",
 "avatar_url": "https://avatars1.githubusercontent.com/u/1622768?v=4",
 "gravatar_id": "",
 "url": "https://api.github.com/users/chauhan130",
 "html_url": "https://github.com/chauhan130",
 "followers_url": "https://api.github.com/users/chauhan130/followers",
 "following_url": "https://api.github.com/users/chauhan130/following{/other_user}",
 "gists_url": "https://api.github.com/users/chauhan130/gists{/gist_id}",
 "starred_url": "https://api.github.com/users/chauhan130/starred{/owner}{/repo}",
 "subscriptions_url": "https://api.github.com/users/chauhan130/subscriptions",
 "organizations_url": "https://api.github.com/users/chauhan130/orgs",
 "repos_url": "https://api.github.com/users/chauhan130/repos",
 "events_url": "https://api.github.com/users/chauhan130/events{/privacy}",
 "received_events_url": "https://api.github.com/users/chauhan130/received_events",
 "type": "User",
 "site_admin": false,
 "name": "Sunil Chauhan",
 "company": "@cloudtv ",
 "blog": "",
 "location": "Ahmedabad, India.",
 "email": null,
 "hireable": true,
 "bio": "iOS and Mac OS Developer",
 "public_repos": 2,
 "public_gists": 0,
 "followers": 2,
 "following": 16,
 "created_at": "2012-04-08T08:41:44Z",
 "updated_at": "2018-08-29T06:14:50Z"
 }
 */
