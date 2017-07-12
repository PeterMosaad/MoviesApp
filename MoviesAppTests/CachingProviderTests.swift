//
//  CachingProviderTests.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/13/17.
//
//

import XCTest
@testable import MoviesApp

class CachingProviderTests: XCTestCase {

  let cachingProvider = DependeciesProvider.sharedInstance.cachingProvider()

  func testCaching() {
    let key = "anyKey"
    let value = ["1", "2", "3", "4"]
    cachingProvider.cache(object: value, forKey: key)
    let loadedValue = cachingProvider.load(objectForKey: key) as! [String]
    XCTAssert(loadedValue == value, "EXPECTED: LoadedValue to be \(String(describing: value))")
  }

  func testLoadInvalidKeys() {
    let key = "invalidKey"
    let loadedValue = cachingProvider.load(objectForKey: key)
    XCTAssertNil(loadedValue)
  }
}
