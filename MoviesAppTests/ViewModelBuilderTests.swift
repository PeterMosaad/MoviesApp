//
//  ViewModelBuilderTests.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/13/17.
//
//

import XCTest
@testable import MoviesApp

class ViewModelBuilderTests: XCTestCase {

  let posterURLBuilder = DependeciesProvider.sharedInstance.moviesPosterURLBuilder()
  func testMoviePosterURLBuilder() {
    let moviePosterPath = "posterPath"
    let expectedFullPath = imagesBaseURL + "w" + String(preferedPosterSize) + "/" + moviePosterPath
    let posterFullPath = posterURLBuilder.fullURLFor(posterPath: moviePosterPath)
    XCTAssert(posterFullPath == expectedFullPath, "EXPECTED: posterFullPath to be \(expectedFullPath)")
  }

  func testMovieViewModelCreation() {
    let movie = Movie()
    let movieViewModel = MovieViewModel(movie: movie, posterURLBuilder: posterURLBuilder)
    XCTAssert(movieViewModel.name == movie.name, "EXPECTED: movieViewModel.name to be \(movie.name)")
    XCTAssert(movieViewModel.releaseDate == movie.releaseDate, "EXPECTED: movieViewModel.releaseDate to be \(movie.releaseDate)")
    XCTAssert(movieViewModel.overView == movie.overView, "EXPECTED: movieViewModel.name to be \(movie.overView)")
    XCTAssert(movieViewModel.posterURL == posterURLBuilder.fullURLFor(posterPath: movie.posterURL), "EXPECTED: movieViewModel.name to be \(posterURLBuilder.fullURLFor(posterPath: movie.posterURL))")
  }
}
