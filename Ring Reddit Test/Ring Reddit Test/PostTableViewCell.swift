//
//  PostTableViewCell.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/18/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import UIKit

protocol PostCellDelegate{
    func tappedThumbnail(sender: PostTableViewCell)
    
}
class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    var topItem: TopItem! {
        didSet {
            titleLabel.text = topItem.title
            authorLabel.text = topItem.author
            timeLabel.text = topItem.created.stringFromDate()
            commentsLabel.text = "Comments: \(topItem.numberOfComments)"
            
            }
        
    }
    
    var delegate: PostCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func thumbnailTapped(_ sender: Any) {
        self.delegate?.tappedThumbnail(sender: self)
        
    }
    
}
