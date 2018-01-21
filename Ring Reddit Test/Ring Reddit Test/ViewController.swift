//
//  ViewController.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/18/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var testTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let cellnib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(cellnib, forCellReuseIdentifier: "postCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        //test data to make sure dynamic cell heights is working
        
        for _ in 0...10 {
            let rand = Int(arc4random_uniform(20))
            var randomlyLongText = ""
            for _ in 0...rand {
                randomlyLongText.append("THIS IS THE TITLE OF THE POST FOR TESTING ")
            }
            testTitles.append(randomlyLongText)
        }

        //test call for API
        let api = API()
        
        api.retrieveData(url: "https://api.reddit.com/top") { (jsonResponse, error) in
            if error == nil {
                //parse json
                print(jsonResponse)
            } else {
                print(error?.localizedDescription)
            }
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        cell.titleLabel.text = testTitles[indexPath.row]
        
        cell.authorLabel.text = "Raiszard"
        
        cell.timeLabel.text = "Posted Just Now"
        
        cell.commentsLabel.text = "123 comments"
        
        cell.thumbnailImageView.backgroundColor = .green
        
        return cell
    }
}









