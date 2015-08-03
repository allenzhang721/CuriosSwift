//
//  CGFloat+Extension.swift
//  CuriosSwift
//
//  Created by Emiaostein on 8/1/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

struct CheckItem {
  let correctPoint: CGFloat
  let distance: CGFloat
  
  func check(input: CGFloat) -> CGFloat {
    if fabs(input - correctPoint) <= distance {
      return correctPoint
    } else {
      return input
    }
  }
}

extension CGFloat {

  func check(item: CheckItem) -> CGFloat {
    
    return item.check(self)
  }
  
}