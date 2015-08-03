//
//  EMBlackCatOptions.swift
//  EMDownloadCacheManager
//
//  Created by Emiaostein on 7/31/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

/**
*  Options to control EMBlackCat behaviors.
*/
public struct BlackCatOptions : RawOptionSetType {
  typealias RawValue = UInt
  private var value: UInt = 0
  init(_ value: UInt) { self.value = value }
  
  /**
  Init an option
  
  :param: value Raw value of the option.
  
  :returns: An option represets input value.
  */
  public init(rawValue value: UInt) { self.value = value }
  
  /**
  Init a None option
  
  :param: nilLiteral Void.
  
  :returns: An option represents None.
  */
  public init(nilLiteral: ()) { self.value = 0 }
  
  /// An option represents None.
  public static var allZeros: BlackCatOptions { return self(0) }
  
  /// Raw value of the option.
  public var rawValue: UInt { return self.value }
  
  static func fromMask(raw: UInt) -> BlackCatOptions { return self(raw) }
  
  /// None options. EMBlackCat will keep its default behavior.
  public static var None: BlackCatOptions { return self(0) }
  
  /// Download in a low priority.
  public static var LowPriority: BlackCatOptions { return BlackCatOptions(1 << 0) }
  
  /// Try to send request to server first. If response code is 304 (Not Modified), use the cached image. Otherwise, download the image and cache it again.
  public static var ForceRefresh: BlackCatOptions { return BlackCatOptions(1 << 1) }
  
  /// Only cache downloaded image to memory, not cache in disk.
  public static var CacheMemoryOnly: BlackCatOptions { return BlackCatOptions(1 << 2) }
  
  /// If set it will dispatch callbacks asynchronously to the global queue DISPATCH_QUEUE_PRIORITY_DEFAULT. Otherwise it will use the queue defined at BlackCatManager.DefaultOptions.queue
  public static var BackgroundCallback: BlackCatOptions { return BlackCatOptions(1 << 3) }

}