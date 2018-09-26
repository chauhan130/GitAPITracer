//
//  APIHelper.swift
//  GitDataTracer
//
//  Created by Sunil Chauhan on 29/06/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import Foundation
import Alamofire

public class APIHelper: NSObject {
    private enum Constants {
        static let commitPathComponent = "commits"
        static let userDetailApiURL = "https://api.github.com/users/"
    }

    public typealias CommitApiCompletion = (CommitApiResult) -> (Void)
    public typealias UserApiCompletion = (UserDetailApiResult) -> (Void)
    public typealias UsersArrayApiCompletion = (UsersArrayApiResult) -> (Void)

    public static let sharedInstance = APIHelper()

    public enum CommitApiResult {
        case success(Array<AuthorAndCommittor>)
        case failure(Swift.Error)
    }
    public enum UserDetailApiResult {
        case success(GitUser)
        case failure(Swift.Error)
    }
    public enum UsersArrayApiResult {
        case success([GitUser])
        case failure(Swift.Error)
    }
    public enum Error: Swift.Error {
        case cannotParseJson
    }

    private var usersArrayForCommitDetails = [AuthorAndCommittor]()
    private var usersArrayApiCompletion: UsersArrayApiCompletion?
    private var fetchedUsers = [GitUser]()
    private var index: Int = 0

    //  https://api.github.com/repos/kubernetes/kubernetes/commits?page=1&per_page=30&name=master
    public func getCommits(repositoryURL: URL, branchName: String = "master", pageIndex: Int, numberOfRecordsPerPage: Int, completion: CommitApiCompletion? = nil) {
        let commitUrl = repositoryURL.appendingPathComponent(Constants.commitPathComponent)

        let parameters = ["page" : pageIndex, "per_page" : numberOfRecordsPerPage]

        request(commitUrl, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if let jsonArray = response.result.value as? [[String: AnyObject]] {
                let authorAndCommitterArray = jsonArray.compactMap({ return AuthorAndCommittor(json: $0 as [String: AnyObject]) })
                let uniqueAuthorAndCommitters: Set<AuthorAndCommittor> = Set(authorAndCommitterArray)
                completion?(.success(Array(uniqueAuthorAndCommitters)))
            } else {
                completion?(.failure(Error.cannotParseJson))
            }
        }
    }

    public func getUserDetailsForCommits(authors: [AuthorAndCommittor], completion: UsersArrayApiCompletion? = nil) {
        self.usersArrayForCommitDetails = authors
        self.usersArrayApiCompletion = completion
        index = 0
        getUserDetailsFor(index: 0)
    }

    private func getUserDetailsFor(index: Int) {
        guard index < self.usersArrayForCommitDetails.count else {
            self.usersArrayApiCompletion?(.success(self.fetchedUsers))
            return
        }

        print("Fetching user details of user: \(index)")

        let userToFetch = self.usersArrayForCommitDetails[index]
        getUserDetails(userLoginName: userToFetch.author.login) { (result) -> (Void) in
            switch result {
            case .success(let gitUser):
                gitUser.email = userToFetch.author.email
                self.fetchedUsers.append(gitUser)
                break
            case .failure(let error):
                print("Could not fetch data for user: \(userToFetch.csvLineString), error: \(error)")
                break
            }
            let nextIndex = index + 1
            self.getUserDetailsFor(index: nextIndex)
        }
    }

    public func getUserDetails(userLoginName: String, completion: UserApiCompletion? = nil) {
        let userApiUrl = "\(Constants.userDetailApiURL)\(userLoginName)"
        request(userApiUrl).responseJSON { (response) in
            if let json = response.result.value as? [String: AnyObject] {
                let user = GitUser(json: json)
                completion?(.success(user))
            } else {
                completion?(.failure(Error.cannotParseJson))
            }
        }
    }
}
