//
//  JRPC.swift
//  JRPCSwiftNio
//
//  Created by Igor Voynov on 08.04.2018.
//

import Foundation

public protocol JRPCResponder {
  func respond(data: Data, completion: @escaping (Data) -> Void)
  func batch(_ request: JRPCRequest, completion: (JRPCResponse) -> Void)
  func execute(_ request: JRPCRequest, completion: (JRPCResponse) -> Void)
}

public extension JRPCResponder {
  
  func respond(data: Data, completion: @escaping (Data) -> Void) {
    if let request = try? JSONDecoder().decode(JRPCRequest.self, from: data) {
      batch(request) { response in
        if request.id != nil {
          completion(response.data)
        }
      }
    } else if let requests = try? JSONDecoder().decode([JRPCRequest].self, from: data) {
      guard requests.count > 0 else {
        completion(ErrorResponse(id: nil, error: .request).data)
        return
      }
      let group = DispatchGroup()
      var responses: [JRPCResponse] = []
      requests.forEach { request in
        group.enter()
        batch(request) { response in
          if request.id != nil {
            responses.append(response)
          }
          group.leave()
        }
      }
      group.notify(queue: .global()) {
        completion(responses.data)
      }
    } else {
      completion(ErrorResponse(id: nil, error: .request).data)
    }
  }
  
  func batch(_ request: JRPCRequest, completion: (JRPCResponse) -> Void) {
    guard request.jsonrpc == "2.0" else {
      completion(ErrorResponse(id: request.id, error: .request))
      return
    }
    execute(request, completion: completion)
  }
}


