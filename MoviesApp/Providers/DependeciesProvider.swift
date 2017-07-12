//
//  DependeciesProvider.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/12/17.
//
//

import Foundation

class DependeciesProvider {
  static let sharedInstance = DependeciesProvider()
  private let apiClient: ApiClient
  init() {
    ApiClient.setup(baseServiceURL)
    apiClient = ApiClient.sharedClient()
  }

  func searchMoviesClient() -> SearchMoviesServiceClient {
    return apiClient
  }

  func cachingProvider() -> CachingProvider {
    return CachingProviderImpl()
  }

  func moviesPosterURLBuilder() -> MoviesPosterURLBuilder {
    return MoviePosterURLBuilder(baseURL: imagesBaseURL, preferedSize: preferedPosterSize)
  }

  func moviesProvider() -> MoviesProvider {
    return MoviesManager(searchClient: searchMoviesClient(), cachingProvider: cachingProvider(), maxCacheSize: maxCacheSize)
  }
}
