//
//  GitUser.swift
//  GitAPITracer
//
//  Created by Sunil Chauhan on 29/06/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import Foundation

public class GitUser: Equatable {
    public var gitId: Int = 0
    public var login: String = ""
    public var email: String = ""
    public var name: String = ""
    public var profileUrl: String = ""

    public var location: String = ""
    public var company: String = ""
    public var blog: String = ""

    init(json: [String: AnyObject]) {
        if let login = json["login"] as? String {
            self.login = login
        }
        if let gitId = json["id"] as? Int {
            self.gitId = gitId
        }
        if let url = json["html_url"] as? String {
            self.profileUrl = url
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
        return "\(name), \(login), \(location), \(company), \(email), \(blog), \(profileUrl)\n"
    }
}
