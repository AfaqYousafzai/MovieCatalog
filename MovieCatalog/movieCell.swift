//
//  movieCell.swift
//  MovieCatalog
//
//  Created by Afaq on 20/04/2019.
//  Copyright © 2019 Afaq. All rights reserved.
//

import UIKit

class movieCell: UITableViewCell {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
