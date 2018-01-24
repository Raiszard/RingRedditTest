//
//  LoadingTableViewCell.swift
//  Ring Reddit Test
//
//  Created by Siar Noorzay on 1/23/18.
//  Copyright © 2018 Ring Reddit Test. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
