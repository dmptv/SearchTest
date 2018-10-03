//
//  SearchResultCellTableViewCell.swift
//  StoreSearch
//
//  Created by 123 on 26.03.2018.
//  Copyright © 2018 123. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    fileprivate var downloadTask: URLSessionDownloadTask?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadTask?.cancel()
        downloadTask = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
       
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = Colors.tintColor
        selectedBackgroundView = selectedView
    }

    
    func configure(for searchResult: SearchResult) {
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "")
        } else {
            artistNameLabel.text = String(format: NSLocalizedString("ARTIST_NAME_LABEL_FORMAT",
                                                                    comment: "Format for artist name label"),
                                          searchResult.artistName,
                                          searchResult.kindForDisplay())
            
            artworkImageView.image = UIImage(named: "Placeholder")
            if let smallURL = URL(string: searchResult.artworkSmallURL) {
                downloadTask = artworkImageView.loadImage(url: smallURL)
                artworkImageView.image = artworkImageView.image?.resizedImage(withBounds: CGSize(width: 60, height: 60))
            }
        }
    }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}









