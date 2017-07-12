//
//  MoviesListPresenter.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/12/17.
//
//

import Foundation

protocol MoviesListScreen: class {
  func updateMoviesTable(moviesList: [MovieViewModel])
  func endTableRefreshing()
}

class MoviesListPresenter {
  private let moviesProvider: MoviesProvider
  private let posterURLBuilder: MoviesPosterURLBuilder
  private var usedSearchQuery: String?
  weak private var viewController: MoviesListScreen?

  init(moviesProvider: MoviesProvider, viewController: MoviesListScreen, posterBuilder: MoviesPosterURLBuilder) {
    self.moviesProvider = moviesProvider
    self.viewController = viewController
    self.posterURLBuilder = posterBuilder
  }

  private func messageFrom(error: Error?) -> String {
    var errorMsg = "No movies found"
    if let err = error {
      errorMsg = err.localizedDescription
    }
    return errorMsg
  }

  private func viewModelsFrom(moviesList: [Movie]) -> [MovieViewModel] {
    var viewModels = [MovieViewModel]()
    for movie in moviesList {
      viewModels.append(MovieViewModel(movie: movie, posterURLBuilder: posterURLBuilder))
    }
    return viewModels
  }

  func gotInitial(moviesList: [Movie], searchQuery: String) {
    usedSearchQuery = searchQuery
    let viewModels = self.viewModelsFrom(moviesList: moviesList)
    viewController?.updateMoviesTable(moviesList: viewModels)
  }

  func pullToRefreshTriggered() {
    guard let query = usedSearchQuery, query.characters.count > 0 else {
      viewController?.endTableRefreshing()
      return
    }
    moviesProvider.searchMovies(query: query) { [weak self] (moviesList, error) in
      guard let `self` = self else { return }
      if let results = moviesList, results.count > 0 {
        let viewModels = self.viewModelsFrom(moviesList: results)
        self.viewController?.updateMoviesTable(moviesList: viewModels)
      } else {
        self.viewController?.updateMoviesTable(moviesList: [])
      }
    }
  }
}
