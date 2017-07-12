//
//  SearchMoviesPresenter.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/12/17.
//
//

import Foundation

protocol SearchMoviesScreen: class {
  func refreshSuggestionsTable(resutls: [String])
  func showLoadingView()
  func hideLoadingView()
  func showError(message: String)
  func openMoviesListScreen(moviesList: [MovieViewModel], searchQuery: String)
  func clearSearchText()
}

class SearchMoviesPresenter {
  private let moviesProvider: MoviesProvider
  private let posterURLBuilder: MoviesPosterURLBuilder
  weak private var viewController: SearchMoviesScreen?

  init(moviesProvider: MoviesProvider, viewController: SearchMoviesScreen, posterBuilder: MoviesPosterURLBuilder) {
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

  func searchTextFieldChanged(text: String) {
    let usedQueries = moviesProvider.getLastSuccessfulSearchQueries()
    let filtered = usedQueries.filter { $0.hasPrefix(text) }
    viewController?.refreshSuggestionsTable(resutls: filtered)
  }

  func searchButtonClicked(searchQuery: String) {
    viewController?.showLoadingView()
    viewController?.refreshSuggestionsTable(resutls: [])
    moviesProvider.searchMovies(query: searchQuery) { [weak self] (moviesList, error) in
      guard let `self` = self else { return }
      self.viewController?.hideLoadingView()
      if let results = moviesList, results.count > 0 {
        let viewModels = self.viewModelsFrom(moviesList: results)
        self.viewController?.clearSearchText()
        self.viewController?.openMoviesListScreen(moviesList: viewModels, searchQuery: searchQuery)
      } else {
        self.viewController?.showError(message: self.messageFrom(error: error))
      }
    }
  }
}
