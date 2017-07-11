//
//  Movie.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/11/17.
//
//

import Foundation
import Unbox

public struct Movie: Unboxable {
  let name: String
  let releaseDate: String
  let overView: String
  let posterURL: String

  public init(unboxer: Unboxer) throws {
    self.name = try unboxer.unbox(key: "title")
    self.releaseDate = try unboxer.unbox(key: "release_date")
    self.overView = try unboxer.unbox(key: "overview")
    self.posterURL = try unboxer.unbox(key: "poster_path")
  }
}
