//
//  BlackCatOptionsInfo.swift
//  EMDownloadCacheManager
//
//  Created by Emiaostein on 7/31/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

/**
*	BlackCatOptionsInfo is a typealias for [BlackCatOptionsInfoKey: Any]. You can use the key-value pairs to control some behaviors of BlackCat.
*/
public typealias BlackCatOptionsInfo = [BlackCatOptionsInfoKey: Any]

/**
Key for BlackCatOptionsInfo

- Options:     Key for options. The value for this key should be a BlackCatOptions.
- TargetCache: Key for target cache. The value for this key should be an DataCache object.BlackCat will use this cache when handling the related operation, including trying to retrieve the cached data and store the downloaded data to it.
- Downloader:  Key for downloader to use. The value for this key should be an DataDownloader object. BlackCat will use this downloader to download the data.
*/
public enum BlackCatOptionsInfoKey {
  case Options
  case TargetCache
  case Downloader
}