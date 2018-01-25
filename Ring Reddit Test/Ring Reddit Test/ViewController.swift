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
    
    let limit = 50//INT64_MAX
    
    @IBOutlet weak var tableView: UITableView!
    
    var topItems: [TopItem] = []
    
    var lastSeenID = ""
    var secondToLastID = ""
    
    var api: API!
    
    @objc func refreshTopItems() {
        topItems = []
        api.lastItem = nil
        lastSeenID = ""
        secondToLastID = ""
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //register the custom cells
        let cellnib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(cellnib, forCellReuseIdentifier: "postCell")
        let loadcellnib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        tableView.register(loadcellnib, forCellReuseIdentifier: "loadingCell")
        
        //dynamically size cells
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        
        //pull to refresh
        let refreshControl = UIRefreshControl()
        let selec = #selector(ViewController.refreshTopItems)
        refreshControl.addTarget(self, action: selec, for: .valueChanged)
        tableView.refreshControl = refreshControl


        //test data to make sure dynamic cell heights is working
        /*
        for _ in 0...10 {
            let rand = Int(arc4random_uniform(20))
            var randomlyLongText = ""
            for _ in 0...rand {
                randomlyLongText.append("THIS IS THE TITLE OF THE POST FOR TESTING ")
            }
            testTitles.append(randomlyLongText)
        }
        */
        
        api = API()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var callInProgess = false
    
    func getMoreItems() {
        if !callInProgess {
            callInProgess = true
            api.retrieveItems(lastSeenItem: self.secondToLastID) { (array) in
                self.callInProgess = false
                guard let newItems = array else {
                    return
                }
                self.topItems.append(contentsOf: newItems)
                
                //call on main thread since UI is being changed
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(secondToLastID, forKey: "secondToLastID")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        secondToLastID = coder.decodeObject(forKey: "secondToLastID") as! String
        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {

        if secondToLastID != "" {
            api.lastItem = nil
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
}

// MARK: Delegates

extension ViewController: PostCellDelegate {
    func tappedThumbnail(sender: PostTableViewCell) {
        guard let fullImageURL = sender.topItem.imageSource else {
            print("item has no image")
            return
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let photoVC = storyBoard.instantiateViewController(withIdentifier: "PhotoDetailsViewController") as! PhotoDetailsViewController
        photoVC.imageURL = fullImageURL
        self.present(photoVC, animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if topItems.count >= limit { return Int(limit) }
        
        //if limit isnt reached show loading cell to get more items
        return topItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= topItems.count {
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingTableViewCell
            loadingCell.loadingIndicator.startAnimating()
            return loadingCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        let currentItem = topItems[indexPath.row]
        cell.topItem = currentItem

        cell.thumbnailImageView.image = UIImage(named: "placeholder")
        
        if currentItem.thumbnailURL != nil {
            //TODO: make this smarter by adding a priority queue and to have low priority for loading images if the cell has been scrolled away
            cell.thumbnailImageView.downloadImageFrom(link: currentItem.thumbnailURL!, contentMode: .scaleAspectFit)
        }

        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= topItems.count {
            //loading cell showing so lets get more items
            self.getMoreItems()
        } else {
            //using this for state restoration to get where the user left off
            self.secondToLastID = lastSeenID
            self.lastSeenID = topItems[indexPath.row].id
        }
    }
    
}

// MARK: Helpers

extension UIImageView {
    func downloadImageFrom(link:URL, contentMode: UIViewContentMode) {

        URLSession.shared.dataTask(with: link, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            }
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
    
}

extension Date {
    
    func stringFromDate() -> String {
        
        let date = self
        
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

