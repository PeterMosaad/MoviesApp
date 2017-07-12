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
  func openMoviesListScreen(moviesList: [Movie], searchQuery: String)
  func clearSearchText()
}

class SearchMoviesPresenter {
  private let moviesProvider: MoviesProvider
  weak private var viewController: SearchMoviesScreen?

  init(moviesProvider: MoviesProvider, viewController: SearchMoviesScreen) {
    self.moviesProvider = moviesProvider
    self.viewController = viewController
  }

  private func messageFrom(error: Error?) -> String {
    var errorMsg = "No movies found"
    if let err = error {
      errorMsg = err.localizedDescription
    }
    return errorMsg
  }

  func searchTextFieldChanged(text: String) {
    let usedQueries = moviesProvider.getLastSuccessfulSearchQueries()
    let filtered = usedQueries.filter { $0.hasPrefix(text) }
    viewController?.refreshSuggestionsTable(resutls: filtered)
  }

  func searchButtonClicked(searchQuery: String) {
    guard searchQuery.characters.count > 0 else {
      viewController?.showError(message: "Please enter search query")
      return
    }
    viewController?.showLoadingView()
    viewController?.refreshSuggestionsTable(resutls: [])
    moviesProvider.searchMovies(query: searchQuery) { [weak self] (moviesList, error) in
      guard let `self` = self else { return }
      self.viewController?.hideLoadingView()
      if let results = moviesList, results.count > 0 {
        self.viewController?.clearSearchText()
        self.viewController?.openMoviesListScreen(moviesList: results, searchQuery: searchQuery)
      } else {
        self.viewController?.showError(message: self.messageFrom(error: error))
      }
    }
  }
}
