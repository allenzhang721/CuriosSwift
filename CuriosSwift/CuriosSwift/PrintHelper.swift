//
//  PrintHelper.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/28/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class debugPrint {
  
  // other swift flags : -D DEBUG
  class func p<T>(value: T,file: String = __FILE__, line: Int = __LINE__ ,function: String = __FUNCTION__) {
    
//    #if DEBUG
    
      print("<\(file.lastPathComponent.stringByDeletingPathExtension) : \(line)>: \(function)")
      print("\n\(value)")
      print("\n-------\n")
      
//      #else
  
//      print(value)
      
//    #endif
  }
}