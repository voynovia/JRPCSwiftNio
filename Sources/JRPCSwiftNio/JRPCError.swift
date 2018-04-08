//
//  JRPCError.swift
//  JRPCSwiftNio
//
//  Created by Igor Voynov on 08.04.2018.
//

import Foundation

public enum JRPCError: Int, Encodable {
  case server = -32000
  case request = -32600
  case method = -32601
  case params = -32602
  case `internal` = -32603
  case parse = -32700
  var message: String {
    switch self {
    case .server:
      return "Server error"
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
    try container.encode(self.rawValue, forKey: .code)
    try container.encode(self.message, forKey: .message)
  }
}
