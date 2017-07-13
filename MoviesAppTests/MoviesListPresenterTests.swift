//
//  MoviesListPresenterTests.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/14/17.
//
//

import XCTest
@testable import MoviesApp

class MoviesListScreenMock: MoviesListScreen {

  var updateMoviesTableCallsCount = 0
  var endTableRefreshingCallsCount = 0

  func updateMoviesTable(moviesList: [MovieViewModel]) {
    updateMoviesTableCallsCount += 1
  }

  func endTableRefreshing() {
    endTableRefreshingCallsCount += 1
  }
}

class MoviesListPresenterTests: XCTestCase {
  var searchClient: MoviesServiceClientMock!
  var moviesListScreen: MoviesListScreenMock!
  var presenter: MoviesListPresenter!

  override func setUp() {
    super.setUp()
    searchClient = MoviesServiceClientMock()
    moviesListScreen = MoviesListScreenMock()
    presenter = MoviesListPresenter(searchClient: searchClient, viewController: moviesListScreen, posterBuilder: DependeciesProvider.sharedInstance.moviesPosterURLBuilder())
    presenter.gotInitial(moviesList: [Movie](), searchQuery: "test")
  }

  func testPullToRefreshTriggeredFlow() {
    presenter.pullToRefreshTriggered()
    XCTAssert(searchClient.searchMoviesCallsCount > 0, "EXPECTED: searchMoviesCallsCount get Called")
    let test = expectation(description: "Just to wait.")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      test.fulfill()
      XCTAssert(self.moviesListScreen.updateMoviesTableCallsCount > 0, "EXPECTED: updateMoviesTable get Called")
      XCTAssert(self.moviesListScreen.endTableRefreshingCallsCount > 0, "EXPECTED: endTableRefreshing get Called")
    }
    waitForExpectations(timeout: 2) {_ in
      print("Eror")
    }
  }
}
