//
//  ColorItem.swift
//  CuriosSwift
//
//  Created by Emiaostein on 7/3/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

struct ColorItem {
    
    let colorHex: String
    
    init(HexString: String) {
        
        colorHex = HexString
    }
    
    func color() -> UIColor {

        return UIColor(hexString: colorHex)!
    }
}