//
//  ITextComponent.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/15/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol ITextComponent: IComponent {
    
    func getSnapshotImage() -> UIImage
    //    var componentModel: ComponentModel{get set}
}