//
//  JRPCHandler.swift
//  JRPCSwiftNio
//
//  Created by Igor Voynov on 08.04.2018.
//

import Foundation
import NIO
import NIOHTTP1

final class JRPCHandler: ChannelInboundHandler {

  public typealias InboundIn = HTTPServerRequestPart
  public typealias OutboundOut = HTTPServerResponsePart

  private var keepAlive = false
  private var execute: Bool = false

  private var uri: String
  private var responder: JRPCResponder

  init(uri: String, responder: JRPCResponder) {
    self.uri = uri
    self.responder = responder
  }

  public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
    let reqPart = self.unwrapInboundIn(data)
    switch reqPart {
    case .head(let request):
      self.keepAlive = request.isKeepAlive
      guard request.uri == uri else {
        ctx.writeAndFlush(self.wrapOutboundOut(.head(.init(version: request.version, status: .notFound))), promise: nil)
        return
      }
      self.execute = true
      ctx.writeAndFlush(self.wrapOutboundOut(.head(.init(version: request.version, status: .ok))), promise: nil)
    case .body(buffer: let buf):
      guard self.execute, let bytes = buf.getBytes(at: 0, length: buf.capacity) else { break }
      var dataOutput = Data()
      let semaphore = DispatchSemaphore(value: 0)
      responder.respond(data: Data(bytes: bytes), completion: { data in
        dataOutput = data
        semaphore.signal()
      })
      semaphore.wait()
      var output = ctx.channel.allocator.buffer(capacity: dataOutput.count)
      output.write(bytes: dataOutput)
      ctx.writeAndFlush(self.wrapOutboundOut(.body(.byteBuffer(output.slice()))), promise: nil)
    case .end:
      self.completeResponse(ctx, trailers: nil, promise: nil)
    }
  }

  private func completeResponse(_ ctx: ChannelHandlerContext,
                                trailers: HTTPHeaders?,
                                promise: EventLoopPromise<Void>?) {
    let promise = self.keepAlive ? promise : (promise ?? ctx.eventLoop.newPromise())
    if !self.keepAlive {
      promise!.futureResult.whenComplete { ctx.close(promise: nil) }
    }
    ctx.writeAndFlush(self.wrapOutboundOut(.end(trailers)), promise: promise)
  }
}
