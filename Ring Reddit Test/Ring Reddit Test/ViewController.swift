//
//  ViewController.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/18/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import UIKit

typealias JsonDict = Dictionary<String, AnyObject>

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var testTitles: [String] = []
    
    var topItems: [TopItem] = []
    
    var lastSeenID: String = ""
    
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
                print(jsonResponse!)
                guard let dict = jsonResponse as? JsonDict else {
                    print("couldn't create dictionary")
                    return
                }
                let type = dict["kind"] as? String
                
                if type == "Listing" {
                    guard let data = dict["data"] as? JsonDict else {
                        print("no data in resonse")
                        return
                    }
                    if let after = data["after"] as? String {
                        api.lastItem = after
                    }
                    
                    
                    guard let items = data["children"] as? [JsonDict] else {
                        print("no items in response")
                        return
                    }
                    
                    print("got \(items.count) items")
                    for item in items {
                        guard item["kind"] as? String == "t3" else {
                            print("wrong type of item")
                            continue
                        }
                        guard let itemDict = item["data"] as? JsonDict else {
                            print("item had no data")
                            continue
                        }
                        let newItem = TopItem()
                        newItem.setupTopItem(json: itemDict)
                        
                        self.topItems.append(newItem)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("invalid response type")
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func stringFromDate(date: Date) -> String {
        
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            return "Last year"
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            return "Last month"
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            return "Last week"
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            return "Yesterday"
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            return "An hour ago"
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            return "A minute ago"
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return testTitles.count
        return topItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let currentItem = topItems[indexPath.row]
        
        cell.titleLabel.text = currentItem.title
        
        cell.authorLabel.text = currentItem.author
        
        cell.timeLabel.text = stringFromDate(date: currentItem.created)
        
        cell.commentsLabel.text = "Comments: \(currentItem.numberOfComments)"
        
//        cell.thumbnailImageView.backgroundColor = .green
        cell.thumbnailImageView.downloadImageFrom(link: currentItem.thumbnailURL!, contentMode: .scaleAspectFit)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.lastSeenID = topItems[indexPath.row].id
    }
    
}

extension UIImageView {
    func downloadImageFrom(link:String, contentMode: UIViewContentMode) {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}









