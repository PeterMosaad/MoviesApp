//
//  MoviesProvider.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/11/17.
//
//

import Foundation

protocol MoviesProvider {
  func searchMovies(query: String, completion: @escaping (_ :[Movie]?, _ :Error?) -> Void)
  func getLastSuccessfulSearchQueries() -> [String]
}

class MoviesManager: MoviesProvider {
  private let searchClient: SearchMoviesServiceClient
  private let cachingProvider: CachingProvider
  private let maxCacheSize: Int
  private let cachingKey = "queriesCachingKeys"

  init(searchClient: SearchMoviesServiceClient, cachingProvider: CachingProvider, maxCacheSize: Int) {
    self.searchClient = searchClient
    self.cachingProvider = cachingProvider
    self.maxCacheSize = maxCacheSize
  }

  private func addSearchQueryToCache(query: String) {
    var queriesList = [String]()
    if let cached = cachingProvider.load(objectForKey: cachingKey) as? [String] {
      queriesList.append(contentsOf: cached)
    }
    if queriesList.count == maxCacheSize {
      queriesList.removeLast()
    }
    if let index = queriesList.index(of: query) {
      queriesList.remove(at:index)
    }
    queriesList.insert(query, at: 0)
    cachingProvider.cache(object: queriesList, forKey: cachingKey)
  }

  func searchMovies(query: String, completion: @escaping (_ :[Movie]?, _ :Error?) -> Void) {

    let parameters = SearchMovieRequestParameters(searchQuery: query)
    let resource = searchClient.searchMovies(parameters)
    resource.addObserver(owner: self, closure: { [weak self] (resource, event) in
      guard let `self` = self else { return }

      switch event {
      case .newData, .notModified:
        if let values = resource.latestData?.content as? [Movie] {
          if values.count > 0 {
            self.addSearchQueryToCache(query: query)
          }
          completion(values, nil)
          resource.removeObservers(ownedBy: self)
        }
      case .error:
        completion(nil, resource.latestError?.cause)
        resource.removeObservers(ownedBy: self)
        break
      default:
        return
      }
    }).load()
  }

  func getLastSuccessfulSearchQueries() -> [String] {
    if let cachedQueries = cachingProvider.load(objectForKey: cachingKey) as? [String] {
      return cachedQueries
    }
    return [String]()
  }
}
