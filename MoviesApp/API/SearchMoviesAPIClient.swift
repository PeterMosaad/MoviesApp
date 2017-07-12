//
//  SearchMoviesAPIClient.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/11/17.
//
//

import Foundation
import Siesta
import Unbox

/**
 Classes implementing this protocol should provide a read-only Siesta Resource for SearchMovies
 */
protocol SearchMoviesServiceClient {
  func searchMovies(_ requestParams: SearchMovieRequestParameters) -> Resource
}

extension ApiClient: SearchMoviesServiceClient {
  func searchMovies(_ requestParams: SearchMovieRequestParameters) -> Resource {
    return resource(ServicePath.searchMovies).withParams(requestParams.queryRepresentation())
  }

  internal func configureForMovieesService() {
    configureTransformer(ServicePath.searchMovies) { (entity: Entity<Unboxer>) -> [Movie] in

      let items: [[String: Any]] = try entity.content.unbox(keyPath: "results") as [[String: Any]]
      let movies = items.flatMap({ (dict: [String: Any]) -> Movie? in
        let moviesUnboxer = Unboxer(dictionary: dict)
        do {
          return try Movie(unboxer: moviesUnboxer)
        } catch {
          return nil
        }
      })
      return movies
    }
  }
}

