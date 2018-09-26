//
//  CommitContributor.swift
//  GitAPITracer
//
//  Created by Sunil Chauhan on 29/06/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import Foundation

public class CommitContributor: Equatable {
    public var name: String = ""
    public var email: String = ""
    public var login: String = ""
    public var gitId: Int = 0
    public var profileUrl: String = ""

    public static func == (lhs: CommitContributor, rhs: CommitContributor) -> Bool {
        return lhs.gitId == rhs.gitId
    }
}
