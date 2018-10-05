//
//  APIHelper.swift
//  GitDataTracer
//
//  Created by Sunil Chauhan on 29/06/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import Foundation
import Alamofire

/**
 The helper class that manages API.
 */
public class APIHelper: NSObject {
    private enum Constants {
        static let commitPathComponent = "commits"
        static let gitBaseUrl = "https://api.github.com"
        static let userDetailApiURL = "\(gitBaseUrl)/users"
        static let gitRepoQueryURL = "\(gitBaseUrl)/repos"
        static let contributorsURLSegment = "contributors"
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

    /**
     Gets Commits from the repository and/or branchName specified with this.

     - Parameters:
        - repositoryName: The repository name, in <User>/<RepositoryName> format.
        - branchName: The name of the branch you want to fetch commit for; or nil to fetch commits from the default branch.
        - pageIndex: The page number of the resultset.
        - numberOfRecordsPerPage: Number of records you want per page. GitHub allows maximum of 100 records par page. Passing more than 100 is just like passing 100.
        - completion: The completion block that will be executed after fetching the result.
     */
    public func getCommits(repositoryName: String, branchName: String? = nil, pageIndex: Int, numberOfRecordsPerPage: Int, completion: @escaping CommitApiCompletion) {
        let repositoryUrl = "\(Constants.gitRepoQueryURL)/\(repositoryName)"
        let commitUrl = repositoryUrl.appending("/\(Constants.commitPathComponent)")

        var parameters: [String : Any] = ["page": pageIndex, "per_page": numberOfRecordsPerPage]
        if let branchName = branchName {
            parameters["name"] = branchName
        }

        request(commitUrl, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                if let jsonArray = value as? [[String: AnyObject]] {
                    let authorAndCommitterArray = jsonArray.compactMap({ return AuthorAndCommittor(json: $0 as [String: AnyObject]) })
                    let uniqueAuthorAndCommitters: Set<AuthorAndCommittor> = Set(authorAndCommitterArray)
                    completion(.success(Array(uniqueAuthorAndCommitters)))
                } else {
                    completion(.failure(Error.cannotParseJson))
                }
                break
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /**
     Gets the user details from the `AuthorAndCommittor` model array passed with this. The `completion` is called when all the requests have been processed.
     - Parameters:
         - authors: Array of `AuthorAndCommittor` model.
         - completion: Block that is to be executed when all requests have been processed.
    */
    public func getUserDetailsForCommits(authors: [AuthorAndCommittor], completion: UsersArrayApiCompletion? = nil) {
        self.usersArrayForCommitDetails = authors
        self.usersArrayApiCompletion = completion
        index = 0
        getUserDetailsFor(index: 0)
    }

    /**
     Gets user detail for `AuthorAndCommittor` model at `index`.
     - Parameters:
         - index: Index of the model in `usersArrayForCommitDetails`.
     */
    private func getUserDetailsFor(index: Int) {
        guard index < self.usersArrayForCommitDetails.count else {
            self.usersArrayApiCompletion?(.success(self.fetchedUsers))
            return
        }

        print("Fetching user details of user: \(index)")

        let userToFetch = self.usersArrayForCommitDetails[index]
        getUserDetails(userLoginName: userToFetch.author.login) { (result) -> (Void) in
            switch result {
            case .success(var gitUser):
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

    /**
     Gets user details from the userLoginName.
     - Parameters:
         - userLoginName: User's login name.
         - completion: Block that will be executed after the user details has been fetched.
     */
    public func getUserDetails(userLoginName: String, completion: @escaping UserApiCompletion) {
        let userApiUrl = "\(Constants.userDetailApiURL)/\(userLoginName)"
        request(userApiUrl).responseData { (response) in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                if let user = try? decoder.decode(GitUser.self, from: data) {
                    completion(.success(user))
                } else {
                    completion(.failure(Error.cannotParseJson))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
//        request(userApiUrl).responseJSON { (response) in
//            switch response.result {
//            case .success(let value):
//                if let json = value as? [String: AnyObject] {
//                    let user = GitUser(json: json)
//                    completion(.success(user))
//                } else {
//                    completion(.failure(Error.cannotParseJson))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
    }

    /**

     */
    public func getContributors(from repository: String, pageIndex: Int, numberOfRecordsPerPage: Int, completion: @escaping UsersArrayApiCompletion) {
        let contributorUrl = "\(Constants.gitRepoQueryURL)/\(repository)/\(Constants.contributorsURLSegment)"
        let parameters: [String : Any] = ["page": pageIndex, "per_page": numberOfRecordsPerPage]

        request(contributorUrl, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                print("value: \(value)")
                if let jsonArray = value as? [[String: AnyObject]] {
                    var contributors = [GitUser]()
                    for json in jsonArray {
                        let user = GitUser(json: json)
                        contributors.append(user)
                    }
                    completion(.success(contributors))
                } else {
                    completion(.failure(Error.cannotParseJson))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
