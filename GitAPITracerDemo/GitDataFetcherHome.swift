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

    private var authorAndCommitterArray = [AuthorAndCommittor]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: -Action Methods

    @IBAction func fetchCommitClicked(button: Any) {
        if let url = URL(string: repoURL.stringValue) {
            actLoader.startAnimation(nil)
            APIHelper.sharedInstance.getCommits(repositoryURL: url, pageIndex: pageIndex.integerValue, numberOfRecordsPerPage: commitsPerPage.integerValue) { (result) -> (Void) in
                self.actLoader.stopAnimation(nil)
                switch result {
                case .success(let authorAndCommitterArray):
                    self.authorAndCommitterArray = authorAndCommitterArray
                    let csvString = authorAndCommitterArray.map({ $0.csvLineString }).joined(separator: "")
                    self.resultText.string = csvString
                    print(csvString)
                    break
                case .failure(let error):
                    let stringToPrint = "Could not fetch commits: \(error)"
                    self.resultText.string = stringToPrint
                    print(stringToPrint)
                }
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
}
