//
//  ServePathsManger.swift
//  CuriosSwift
//
//  Created by Emiaostein on 8/10/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

private let defaultManagerInstance = ServePathsManger()

public class ServePathsManger {
  
  private let manager = ServePathsManger()
  private var imagePath = ""
  private var publishPath = ""
  private var templatePath = ""
  
  public class var shareManger: ServePathsManger {
    return defaultManagerInstance
  }
  
  func getServePaths() {
    
    
    
  }
  
}