//
//  JRPCError.swift
//  JRPCSwiftNio
//
//  Created by Igor Voynov on 08.04.2018.
//

import Foundation

public enum JRPCError: Encodable {
  case server(message: String), request, method, params, `internal`, parse
  
  var code: Int {
    switch self {
    case .server:
      return -32000
    case .request:
      return -32600
    case .method:
      return -32601
    case .params:
      return -32602
    case .internal:
      return -32603
    case .parse:
      return -32700
    }
  }
  
  var message: String {
    switch self {
    case .server(let message):
      return message
    case .request:
      return "Invalid Request"
    case .method:
      return "Method not found"
    case .params:
      return "Invalid params"
    case .internal:
      return "Internal error"
    case .parse:
      return "Parse error"
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case code = "code"
    case message = "message"
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.code, forKey: .code)
    try container.encode(self.message, forKey: .message)
  }
}
