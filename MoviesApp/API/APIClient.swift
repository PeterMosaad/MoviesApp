//
//  APIClient.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/11/17.
//
//

import Foundation
import Siesta
import Alamofire
import Unbox

let baseServiceURL = "https://api.themoviedb.org/3/"

/**
 A struct the encapsulates all service paths for better access
 */
struct ServicePath {
  static let searchMovies = "/search/movie"
}

fileprivate var singleton: ApiClient?

/**
 Centralized RESTful instance to communicate with the API
 */
public class ApiClient: Service {
  /**
   Default accessor for singleton.
   - Returns: Singleton ApiClient instance.
   */
  static public func sharedClient() -> ApiClient {
    if singleton == nil {
      assertionFailure("ApiClient must be configured first via ApiClient.setup()")
      return ApiClient(baseServiceURL)
    } else {
      return singleton!
    }
  }

  /**
   Required configurator for ApiClient.
   Not calling this method as a first accessor will raise an exception on Debug environments.
   - Parameters:
   - baseURL: Base URL for the API.
   */
  static public func setup(_ baseURL: String) {
    singleton = ApiClient(baseURL)
  }

  private init(_ baseURL: String) {
    super.init(baseURL: baseURL,
               useDefaultTransformers: true,
               networking: AlamofireProvider().manager)

    let unboxerTransformer = ResponseContentTransformer<[String: Any], Unboxer> {
      return Unboxer(dictionary: $0.content)
    }

    configure {
      $0.pipeline[.parsing].add(unboxerTransformer, contentTypes: ["*/json"])
    }
    configureForMovieesService()
  }
}


internal extension Resource {
  internal func withParams(_ dictionary: [String: String?]) -> Siesta.Resource {
    var resource = self
    for (key, value) in dictionary {
      resource = resource.withParam(key, value)
    }
    return resource
  }
}
