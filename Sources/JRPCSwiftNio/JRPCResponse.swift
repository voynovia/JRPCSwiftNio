//
//  JRPCResponse.swift
//  JRPCSwiftNio
//
//  Created by Igor Voynov on 08.04.2018.
//

import Foundation

public protocol JRPCResponse: Encodable {
  var jsonrpc: String { get }
  var data: Data { get }
  var id: Int? { get set }
}

public extension JRPCResponse {
  var jsonrpc: String {
    return "2.0"
  }
  var data: Data {
    return try! JSONEncoder().encode(self)
  }
}

extension Sequence where Iterator.Element == JRPCResponse {
  var data: Data {
    let str = self.reduce("[", {$0 + String(data: $1.data, encoding: .utf8)! + ","}) + "]"
    return str.data(using: .utf8)!
  }
}

private enum CodingKeys: String, CodingKey {
  case jsonrpc = "jsonrpc"
  case id = "id"
  case error = "error"
  case result = "result"
}

public class ErrorResponse: JRPCResponse {
  public var id: Int?
  public var error: JRPCError?
  
  public init(id: Int?, error: JRPCError?) {
    self.id = id
    self.error = error
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.jsonrpc, forKey: .jsonrpc)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.error, forKey: .error)
  }
}

public class ResultResponse<T: Encodable>: JRPCResponse {
  public var id: Int?
  public var result: T?
  
  public init(id: Int?, result: T?) {
    self.id = id
    self.result = result
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.jsonrpc, forKey: .jsonrpc)
    try container.encode(self.id, forKey: .id)
    try container.encode(self.result, forKey: .result)
  }
}
