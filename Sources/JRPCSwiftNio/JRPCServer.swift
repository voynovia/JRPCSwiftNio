//
//  JRPCServer.swift
//  JRPCSwiftNio
//
//  Created by Igor Voynov on 08.04.2018.
//

import Foundation
import NIO
import NIOHTTP1

public class JRPCServer {
  private var host: String
  private var port: Int
  private var group: MultiThreadedEventLoopGroup
  private var threadPool: BlockingIOThreadPool
  private var fileIO: NonBlockingFileIO
  private var uri: String
  
  public var responder: JRPCResponder
  
  public init(uri: String, host: String, port: Int, responder: JRPCResponder, eventLoopThreads: Int = System.coreCount, poolThreads: Int = 6) {
    self.uri = uri
    self.host = host
    self.port = port
    self.responder = responder
    
    group = MultiThreadedEventLoopGroup(numThreads: eventLoopThreads)
    threadPool = BlockingIOThreadPool(numberOfThreads: poolThreads)
    threadPool.start()
    
    fileIO = NonBlockingFileIO(threadPool: threadPool)
  }
  
  public func run() {
    let bootstrap = ServerBootstrap(group: self.group)
      // Specify backlog and enable SO_REUSEADDR for the server itself
      .serverChannelOption(ChannelOptions.backlog, value: 256)
      .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
      
      // Set the handlers that are applied to the accepted Channels
      .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline().then {
          channel.pipeline.add(handler: JRPCHandler(uri: self.uri, responder: self.responder))
        }
      }
      
      // Enable TCP_NODELAY and SO_REUSEADDR for the accepted Channels
      .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
      .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
      .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
      .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)
    
    do {
      let channel = try bootstrap.bind(host: host, port: port).wait()
      
      print("Server started and listening on \(channel.localAddress!)")
      
      // This will never unblock as we don't close the ServerChannel
      try channel.closeFuture.wait()
      
    } catch {
      print("Error starting server")
    }
  }
  
  public func stop() {
    try? group.syncShutdownGracefully()
    try? threadPool.syncShutdownGracefully()
  }
}

