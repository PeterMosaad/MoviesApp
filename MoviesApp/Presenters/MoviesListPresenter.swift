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
  private let searchClient: SearchMoviesServiceClient
  private let posterURLBuilder: MoviesPosterURLBuilder
  private var usedSearchQuery: String?
  weak private var viewController: MoviesListScreen?

  init(searchClient: SearchMoviesServiceClient, viewController: MoviesListScreen, posterBuilder: MoviesPosterURLBuilder) {
    self.searchClient = searchClient
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
    let parameters = SearchMovieRequestParameters(searchQuery: query)
    let resource = searchClient.searchMovies(parameters)
    resource.addObserver(owner: self, closure: { [weak self] (resource, event) in
      guard let `self` = self else { return }

      switch event {
      case .newData, .notModified:
        if let values = resource.latestData?.content as? [Movie] {
          let viewModels = self.viewModelsFrom(moviesList: values)
          self.viewController?.updateMoviesTable(moviesList: viewModels)
          self.viewController?.endTableRefreshing()
          resource.removeObservers(ownedBy: self)
        }
      case .error:
        self.viewController?.updateMoviesTable(moviesList: [])
        resource.removeObservers(ownedBy: self)
        break
      default:
        return
      }
    }).load()
  }
}
