//
//  MoviesProviderTests.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/13/17.
//
//

import XCTest
import Siesta
@testable import MoviesApp

class MoviesServiceClientMock: SearchMoviesServiceClient {

  let shouldSuccess: Bool
  var searchMoviesCallsCount = 0
  let tempMovie = Movie()
  init(toSuccess: Bool = true) {
    shouldSuccess = toSuccess
  }
  func searchMovies(_ requestParams: SearchMovieRequestParameters) -> Resource {
    searchMoviesCallsCount += 1
    var service: Service
    if shouldSuccess {
      service = MockService(responseToBe: [tempMovie])
    } else {
      service = MockService(responseToBe: [])
    }
    return service.resource("")
  }
}

extension Movie {
  init() {
    name = "name"
    releaseDate = "releaseDate"
    overView = "overView"
    posterURL = "posterURL"
  }
}

class MoviesProviderTests: XCTestCase {

  var searchClient: MoviesServiceClientMock!
  var provider: MoviesProvider!
  var cachingProvider: CachingProviderMock!
  let maxCacheSize = 1

  override func setUp() {
    searchClient = MoviesServiceClientMock()
    cachingProvider = CachingProviderMock()
    provider = MoviesManager(searchClient: searchClient, cachingProvider: cachingProvider, maxCacheSize: maxCacheSize)
  }

  func testCallingServiceWhenSearchRequested() {
    provider.searchMovies(query: "query") { (_, _) in }
    XCTAssert(searchClient.searchMoviesCallsCount > 0, "EXPECTED: Search client is called")
  }

  func testSuccessQueriesAreCached() {

    let test = expectation(description: "Request")
    provider.searchMovies(query: "query") { (moviesList, error) in
      XCTAssert(self.cachingProvider.cacheObjectCallsCount > 0, "EXPECTED: Caching Provider is called")
      test.fulfill()
    }
    waitForExpectations(timeout: 5) {_ in
      print("error")
    }
  }

  func testFailedQueriesAreNotCached() {

    searchClient = MoviesServiceClientMock(toSuccess: false)
    provider = MoviesManager(searchClient: searchClient, cachingProvider: cachingProvider, maxCacheSize: maxCacheSize)
    let test = expectation(description: "Request")
    provider.searchMovies(query: "query") { (moviesList, error) in
      XCTAssert(self.cachingProvider.cacheObjectCallsCount == 0, "EXPECTED: Caching Provider is not called")
      test.fulfill()
    }
    waitForExpectations(timeout: 5) {_ in
      print("error")
    }
  }

  func testGetSuccessfulSearchQueries() {
    let query = "query"
    let expectedQueries = ["query"]
    let test = expectation(description: "Request")
    provider.searchMovies(query: query) { (moviesList, error) in
      let queries = self.provider.getLastSuccessfulSearchQueries()
      XCTAssert(queries == expectedQueries, "EXPECTED: LoadedQueries to be \(String(describing: expectedQueries))")
      test.fulfill()
    }
    waitForExpectations(timeout: 5) {_ in
      print("error")
    }
  }

  func testCachingRespectMaxSize() {

    let test = expectation(description: "Request")
    provider.searchMovies(query: "query") { (moviesList, error) in
      self.provider.searchMovies(query: "query2") { (moviesList, error) in
        let queries = self.provider.getLastSuccessfulSearchQueries()
        XCTAssert(queries.count <= self.maxCacheSize, "EXPECTED: Caching Only results according to max cache size")
        test.fulfill()
      }
    }
    waitForExpectations(timeout: 5) {_ in
      print("error")
    }
  }

  func testCachingRemovesDuplicate() {

    let test = expectation(description: "Request")
    provider = MoviesManager(searchClient: searchClient, cachingProvider: cachingProvider, maxCacheSize: 2)
    provider.searchMovies(query: "query") { (moviesList, error) in
      self.provider.searchMovies(query: "query") { (moviesList, error) in
        let queries = self.provider.getLastSuccessfulSearchQueries()
        let queriesSet = Set(queries)// To remove Duplicates
        XCTAssert(queries.count <= queriesSet.count, "EXPECTED: Caching removes duplicate results")
        test.fulfill()
      }
    }
    waitForExpectations(timeout: 5) {_ in
      print("error")
    }
  }

  func testCachingInFIFO() {

    let query1 = "query1"
    let query2 = "query2"
    let test = expectation(description: "Request")
    provider = MoviesManager(searchClient: searchClient, cachingProvider: cachingProvider, maxCacheSize: 2)
    provider.searchMovies(query: query1) { (moviesList, error) in
      self.provider.searchMovies(query: query2) { (moviesList, error) in
        let queries = self.provider.getLastSuccessfulSearchQueries()
        XCTAssert(queries.first == query2, "EXPECTED: Caching should be in order FIFO")
        test.fulfill()
      }
    }
    waitForExpectations(timeout: 5) {_ in
      print("error")
    }
  }

}
