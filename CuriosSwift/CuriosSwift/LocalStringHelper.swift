//
//  LocalStringHelper.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/28/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

func localString(key: String) -> String {
  
  return NSLocalizedString(key, comment: key)
  
}