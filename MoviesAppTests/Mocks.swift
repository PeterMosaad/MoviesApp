//
//  Mocks.swift
//  MoviesApp
//
//  Created by Peter Mosaad on 7/13/17.
//
//

import Foundation
import Siesta
@testable import MoviesApp

class CachingProviderMock: CachingProvider {
  var cacheObjectCallsCount = 0
  var loadObjectCallsCount = 0
  var persistenceSimulator = [String: Any]()

  func cache(object: Any, forKey key: String) {
    cacheObjectCallsCount += 1
    persistenceSimulator.updateValue(object, forKey: key)
  }

  func load(objectForKey key: String) -> Any? {
    loadObjectCallsCount += 1
    return persistenceSimulator[key]
  }
}

struct NetworkStub: NetworkingProvider {
  var responses: [String:ResponseStub] = [:]

  func startRequest(
    _ request: URLRequest,
    completion: @escaping RequestNetworkingCompletionCallback)
    -> RequestNetworking {
      let responseStub = responses[request.url!.path]
      let statusCode = 200
      let response = HTTPURLResponse(
        url: request.url!,
        statusCode: statusCode,
        httpVersion: "HTTP/1.1",
        headerFields: [:])

      completion(response, responseStub?.data, nil)
      return RequestStub()
  }
}

struct ResponseStub {
  let contentType: String = "*/json"
  let data = Data()
}

struct RequestStub: RequestNetworking {
  func cancel() { }

  var transferMetrics: RequestTransferMetrics {
    return RequestTransferMetrics(
      requestBytesSent: 0,
      requestBytesTotal: nil,
      responseBytesReceived: 0,
      responseBytesTotal: nil)
  }
}

class MockService: Service {
  init(responseToBe: Any) {
    super.init(baseURL: "http://test.ing",
               useDefaultTransformers: true,
               networking: NetworkStub())

    configureTransformer("") { (entity: Entity<Any>) -> Any in
      return responseToBe
    }
  }
}
