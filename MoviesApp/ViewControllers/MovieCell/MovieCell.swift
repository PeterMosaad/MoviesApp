//
//  MovieCell.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/13/17.
//
//

import Foundation
import UIKit
import AlamofireImage

class MovieCell : UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var releaseDataLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  @IBOutlet weak var posterImageView: UIImageView!

  class func cellIdentifier() -> String {
    return "MovieCell"
  }

  override func awakeFromNib() {
    posterImageView.layer.cornerRadius = posterImageView.frame.size.width / 2.0
    posterImageView.layer.borderWidth = 1.5
    posterImageView.layer.borderColor = releaseDataLabel.textColor.cgColor
  }

  func updateCell(movieViewModel: MovieViewModel) {
    nameLabel.text = movieViewModel.name
    releaseDataLabel.text = movieViewModel.releaseDate
    overviewLabel.text = movieViewModel.overView
    let placeHolderImage = UIImage(named: "placeHolder.png")
    if let posterURL = URL(string: movieViewModel.posterURL) {
      posterImageView.af_setImage(withURL: posterURL , placeholderImage: placeHolderImage)
    } else {
      posterImageView.image = placeHolderImage
    }
  }
}
