//
//  AuthorAndCommittor.swift
//  GitAPITracer
//
//  Created by Sunil Chauhan on 29/06/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import Foundation

public class AuthorAndCommittor: Equatable, Hashable {
    public var hashValue: Int {
        return author.gitId ^ committor.gitId
    }

    public let author: CommitContributor
    public let committor: CommitContributor

    init(author: CommitContributor, committor: CommitContributor) {
        self.author = author
        self.committor = committor
    }

    init?(json: [String: AnyObject]) {
        author = CommitContributor()
        committor = CommitContributor()

        if let commitNode = json["commit"] as? [String: AnyObject] {
            if let authorNode = commitNode["author"] as? [String: AnyObject] {
                if let name = authorNode["name"] as? String {
                    author.name = name
                }
                if let email = authorNode["email"] as? String {
                    author.email = email
                }
            }

            if let commitNode = commitNode["committer"] as? [String: AnyObject] {
                if let name = commitNode["name"] as? String {
                    committor.name = name
                }
                if let email = commitNode["email"] as? String {
                    committor.email = email
                }
            }
        }

        // Parse Author specific data
        if let authorJson = json["author"] as? [String: AnyObject] {
            if let login = authorJson["login"] as? String {
                author.login = login
            }
            if let gitId = authorJson["id"] as? Int {
                author.gitId = gitId
            }
            if let profileUrl = authorJson["url"] as? String {
                author.profileUrl = profileUrl
            }
        } else {
            return nil
        }

        // Parse Committer specific data
        if let committerJson = json["committer"] as? [String: AnyObject] {
            if let login = committerJson["login"] as? String {
                committor.login = login
            }
            if let gitId = committerJson["id"] as? Int {
                committor.gitId = gitId
            }
            if let profileUrl = committerJson["url"] as? String {
                committor.profileUrl = profileUrl
            }
        } else {
            return nil
        }
    }

    public var csvLineString: String {
        return "\(author.gitId), \(author.login), \(author.email), \(author.name), \(author.profileUrl), \(committor.gitId), \(committor.login), \(committor.email), \(committor.name), \(committor.profileUrl)\n"
    }

    public static func == (lhs: AuthorAndCommittor, rhs: AuthorAndCommittor) -> Bool {
        return lhs.author == rhs.author && lhs.committor == rhs.committor
    }
}
