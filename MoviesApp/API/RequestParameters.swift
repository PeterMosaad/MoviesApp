//
//  RequestParameters.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/11/17.
//
//

import Foundation

let defaultAPIKey = "2696829a81b1b5827d515ff121700838"

enum QueryKeys {
  static let apiKey = "api_key"
  static let searchQuery = "query"
}

class RequestParameters {
  let apiKey: String

  init(apiKey: String = defaultAPIKey) {
    self.apiKey = apiKey
  }

  func queryRepresentation() -> [String: String?] {
    var queryParams = [String: String]()
    queryParams[QueryKeys.apiKey] = apiKey
    return queryParams
  }
}

class SearchMovieRequestParameters : RequestParameters {
  let searchQuery: String

  init(searchQuery: String) {
    self.searchQuery = searchQuery
    super.init()
  }

  override func queryRepresentation() -> [String: String?] {
    var queryParams = super.queryRepresentation()
    queryParams[QueryKeys.searchQuery] = searchQuery
    return queryParams
  }
}
