//
//  IFile.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IFile: NSObjectProtocol {
    
    func fileGetSuperPath(file: IFile) -> String
}