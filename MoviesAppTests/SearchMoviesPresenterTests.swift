//
//  SearchMoviesPresenterTests.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/13/17.
//
//

import XCTest
@testable import MoviesApp

class SearchMoviesScreenMock: SearchMoviesScreen {

  var refreshSuggestionsTableCallsCount = 0
  var showLoadingViewCallsCount = 0
  var hideLoadingViewCallsCount = 0
  var showErrorCallsCount = 0
  var openMoviesListScreeCallsCount = 0
  var clearSearchTextCallsCount = 0

  func refreshSuggestionsTable(resutls: [String]) {
    refreshSuggestionsTableCallsCount += 1
  }
  func showLoadingView() {
    showLoadingViewCallsCount += 1
  }
  func hideLoadingView() {
    hideLoadingViewCallsCount += 1
  }
  func showError(message: String) {
    showErrorCallsCount += 1
  }
  func openMoviesListScreen(moviesList: [Movie], searchQuery: String) {
    openMoviesListScreeCallsCount += 1
  }
  func clearSearchText() {
    clearSearchTextCallsCount += 1
  }
}

class MoviesProviderMock : MoviesProvider {

  var shouldReturnMoviesList = true
  var searchMoviesCallsCount = 0
  var getLastSuccessfulSearchQueriesCallsCount = 0

  func searchMovies(query: String, completion: @escaping (_ :[Movie]?, _ :Error?) -> Void) {
    searchMoviesCallsCount += 1
    var moviesList = [Movie]()
    if shouldReturnMoviesList {
      moviesList.append(Movie())
    }
    completion(moviesList, nil)
  }
  func getLastSuccessfulSearchQueries() -> [String] {
    getLastSuccessfulSearchQueriesCallsCount += 1
    return [String]()
  }
}

class SearchMoviesPresenterTests: XCTestCase {
  var moviesProvider: MoviesProviderMock!
  var searchScreen: SearchMoviesScreenMock!
  var presenter: SearchMoviesPresenter!

  override func setUp() {
    super.setUp()
    moviesProvider = MoviesProviderMock()
    searchScreen = SearchMoviesScreenMock()
    presenter = SearchMoviesPresenter(moviesProvider: moviesProvider, viewController: searchScreen)
  }

  func testSearchTextFieldChangedFlow() {
    presenter.searchTextFieldChanged(text: "text")
    XCTAssert(searchScreen.refreshSuggestionsTableCallsCount > 0, "EXPECTED: refreshSuggestionsTable get Called")
  }

  func testSuccessfulSearchFlow() {
    presenter.searchButtonClicked(searchQuery: "text")
    XCTAssert(searchScreen.showLoadingViewCallsCount > 0, "EXPECTED: showLoading get Called")
    XCTAssert(searchScreen.refreshSuggestionsTableCallsCount > 0, "EXPECTED: Hide suggestion table get Called")
    let test = expectation(description: "Just to wait.")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      test.fulfill()
      XCTAssert(self.searchScreen.hideLoadingViewCallsCount > 0, "EXPECTED: Hide Loading view get Called")
      XCTAssert(self.searchScreen.clearSearchTextCallsCount > 0, "EXPECTED: Clear text get Called")
      XCTAssert(self.searchScreen.openMoviesListScreeCallsCount > 0, "EXPECTED: Open movies list screen get Called")
    }
    waitForExpectations(timeout: 2) {_ in
      print("Eror")
    }
  }

  func testFailureSearchFlow() {
    moviesProvider.shouldReturnMoviesList = false
    presenter.searchButtonClicked(searchQuery: "text")
    XCTAssert(searchScreen.showLoadingViewCallsCount > 0, "EXPECTED: showLoading get Called")
    XCTAssert(searchScreen.refreshSuggestionsTableCallsCount > 0, "EXPECTED: Hide suggestion table get Called")
    let test = expectation(description: "Just to wait.")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      test.fulfill()
      XCTAssert(self.searchScreen.hideLoadingViewCallsCount > 0, "EXPECTED: Hide Loading view get Called")
      XCTAssert(self.searchScreen.showErrorCallsCount > 0, "EXPECTED: Show error get Called")
    }
    waitForExpectations(timeout: 2) {_ in
      print("Eror")
    }
  }

}
