//
//  GitDataFetcherHome.swift
//  GitAPITracer
//
//  Created by Sunil Chauhan on 29/06/18.
//  Copyright © 2018 Sunil Chauhan. All rights reserved.
//

import Cocoa
import GitAPITracer

class GitDataFetcherHome: NSViewController {
    @IBOutlet var repoURL: NSTextField!
    @IBOutlet var commitsPerPage: NSTextField!
    @IBOutlet var pageIndex: NSTextField!
    @IBOutlet var resultText: NSTextView!
    @IBOutlet var actLoader: NSProgressIndicator!
    @IBOutlet var userLoader: NSProgressIndicator!
    @IBOutlet var userNameTextField: NSTextField!
    @IBOutlet var userDetailTextView: NSTextView!

    private var authorAndCommitterArray = [AuthorAndCommittor]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: -Action Methods

    @IBAction func fetchCommitClicked(button: Any) {
        actLoader.startAnimation(nil)

        APIHelper.sharedInstance.getContributors(from: repoURL.stringValue, pageIndex: pageIndex.integerValue,
                                                 numberOfRecordsPerPage: commitsPerPage.integerValue) { (result) -> (Void) in
                                                    self.actLoader.stopAnimation(nil)
                                                    switch result {
                                                    case .success(let users):
                                                        let csvString = users.map({ $0.csvLineString }).joined()
                                                        self.resultText.string = csvString
                                                        break
                                                    case .failure(let error):
                                                        let stringToPrint = "Could not fetch contributors: \(error)"
                                                        self.resultText.string = stringToPrint
                                                    }
        }
    }

    @IBAction func fetchUserDetailsForCommits(button: Any) {
        actLoader.startAnimation(nil)

        APIHelper.sharedInstance.getUserDetailsForCommits(authors: authorAndCommitterArray) { (result) -> (Void) in
            self.actLoader.stopAnimation(nil)
            switch result {
            case .success(let gitUsers):
                let csvString = gitUsers.map({ $0.csvLineString }).joined(separator: "")
                self.resultText.string = csvString
            case .failure(let error):
                print("Error: \(error)")
                break
            }
        }
    }

    @IBAction func fetchUserDetailsFromUserName(button: Any) {
        guard userNameTextField.stringValue.count > 0 else {
            return
        }
        userLoader.startAnimation(nil)
        APIHelper.sharedInstance.getUserDetails(userLoginName: userNameTextField.stringValue) { (result) -> (Void) in
            self.userLoader.stopAnimation(nil)
            switch result {
            case .success(let user):
                self.userDetailTextView.string = user.csvLineString
            case .failure(let error):
                print("Error: \(error)")
                self.userDetailTextView.string = error.localizedDescription
            }
        }
    }
}
