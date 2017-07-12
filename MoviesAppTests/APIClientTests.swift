//
//  APIClientTests.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/13/17.
//
//

import XCTest
import Siesta
@testable import MoviesApp

class APIClientTests: XCTestCase {
    
  func testClientSetup() {
    ApiClient.setup(baseServiceURL)
    XCTAssertNotNil(ApiClient.sharedClient(), "There is no valid instance")
  }

  func testSingletonConsistency() {
    ApiClient.setup(baseServiceURL)
    let obj1 = ApiClient.sharedClient()
    let obj2 = ApiClient.sharedClient()
    XCTAssert(obj1 === obj2, "Singleton is not returning expected equality")
  }

  func testResourceMultipleParameterAddition() {
    let resource1 = Service().resource(absoluteURL: URL(string: "baseUrl")).withParam("key3", "value3")
      .withParam("key1", "value1").withParam("key2", nil)

    let resource2 = Service().resource(absoluteURL: URL(string: "baseUrl"))
      .withParams(["key2": nil, "key1": "value1", "key3": "value3"])

    XCTAssertEqual(resource1.url, resource2.url)
  }

  func testRequestParamsQueryRepresentation() {
    let searchQuery = "searchQuery"
    let resourceParams = SearchMovieRequestParameters(searchQuery: searchQuery)
    let expectedParams = ["api_key": defaultAPIKey, "query": searchQuery]
    let queryParams = resourceParams.queryRepresentation() as! [String: String]
    XCTAssert(expectedParams == queryParams, "EXPECTED: parameeters to be \(String(describing: expectedParams))")
  }

  func testValidSearchRequest() {

    let test = expectation(description: "Search Request failed.")
    ApiClient.setup(baseServiceURL)
    let apiClient = ApiClient.sharedClient()
    let validRequestParams = SearchMovieRequestParameters(searchQuery: "test")
    apiClient.searchMovies(validRequestParams).addObserver(owner: self, closure: { (_, event) in
      if case .newData = event {
        test.fulfill()
      }
    }).load()

    waitForExpectations(timeout: 5) {_ in
      print("error")
    }
  }
}
