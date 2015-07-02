//
//  PannelItem.swift
//  CuriosSwift
//
//  Created by Emiaostein on 6/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

struct Item {
    
    let name: String
    let iconName: String
    let titleName: String
    let action: IContainer? -> Void
}

struct EventItem {
    
    let name: String
    let iconName: String
    let titleName: String
    let action: () -> ()
}