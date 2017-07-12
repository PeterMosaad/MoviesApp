//
//  ImagesURLBuilder.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/12/17.
//
//

import Foundation

protocol MoviesPosterURLBuilder {
  func fullURLFor(posterPath: String) -> String
}

struct MovieViewModel {
  let name: String
  let releaseDate: String
  let overView: String
  let posterURL: String

  init(movie: Movie, posterURLBuilder: MoviesPosterURLBuilder) {
    name = movie.name
    releaseDate = movie.releaseDate
    overView = movie.overView
    posterURL = posterURLBuilder.fullURLFor(posterPath: movie.posterURL)
  }
}

class MoviePosterURLBuilder: MoviesPosterURLBuilder {
  let baseImagesURL: String
  let preferedSize: Int

  init(baseURL: String, preferedSize: Int) {
    self.baseImagesURL = baseURL
    self.preferedSize = preferedSize
  }

  func fullURLFor(posterPath: String) -> String {
    return baseImagesURL + "w" + String(preferedSize) + "/" + posterPath
  }
}
