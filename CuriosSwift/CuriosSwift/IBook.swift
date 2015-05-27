//
//  IBook.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/25/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

protocol IBook {
    
}

protocol bookMangerInterface: IBook {
    
    func createBook(aBookID: String) -> Bool
    func deleteBook(abookID: String) -> Bool
}

protocol templateMangeInterface: IBook {
    
    func loadTemplates()
    func saveTemplateListInfoToLocal()
    
}
