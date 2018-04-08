//
//  JRPCRequest.swift
//  JRPCSwiftNio
//
//  Created by Igor Voynov on 08.04.2018.
//

import Foundation

public class JRPCRequest: Decodable {
  let jsonrpc: String
  public let id: Int?
  public let method: String

  private let values: KeyedDecodingContainer<JRPCRequest.CodingKeys>

  enum CodingKeys: String, CodingKey {
    case jsonrpc = "jsonrpc"
    case method = "method"
    case params = "params"
    case id = "id"
  }

  public required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    jsonrpc = try values.decode(String.self, forKey: .jsonrpc)
    method = try values.decode(String.self, forKey: .method)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    self.values = values
  }

  public func getParams<T>(_ type: T.Type) throws -> T where T: Decodable {
    return try values.decode(T.self, forKey: .params)
  }
}
