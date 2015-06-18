//
//  TemplatesManager.swift
//  CuriosSwift
//
//  Created by Emiaostein on 5/27/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation
import Mantle

class TemplatesManager: templateMangeInterface {
    
    static let instanShare = TemplatesManager()
    var templateList = [TemplateListModel]()
    
    func duplicateTemplateTo(templateId: String, toUrl: NSURL) -> Bool {
        
        let existTemplate = templateList.filter { (templateListModel: TemplateListModel) -> Bool in
           return templateListModel.bookID == templateId
        }
        
        assert(existTemplate.count > 0, "template not exist")
        
        let specialTemplateUrl = documentDirectory(templates,templateId)
        
        if NSFileManager.defaultManager().fileExistsAtPath(specialTemplateUrl.path!) {
            
        }
        
        let error = NSErrorPointer()
        if NSFileManager.defaultManager().copyItemAtURL(specialTemplateUrl, toURL: toUrl, error: error) {
            
            // change the new book id
            let newId = toUrl.lastPathComponent!
            let mainjsonUrl = toUrl.URLByAppendingPathComponent(main_json)
            let mainjsonData = NSData(contentsOfURL: mainjsonUrl)
            var json = NSJSONSerialization.JSONObjectWithData(mainjsonData!, options: NSJSONReadingOptions(0), error: nil) as! [NSObject : AnyObject]
            json["ID"] = newId
            var jsonData = NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions(0), error: nil)
            if (jsonData?.writeToURL(mainjsonUrl, atomically: true) != nil) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

// MARK: - templateMangeInterface
// MARK: - 
extension TemplatesManager {
    
    func loadTemplates() {
        
        let publicTemplateFileURL = documentDirectory(templates,templateList_)
        if let data = NSData(contentsOfURL: publicTemplateFileURL) {
            
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as! [AnyObject]
            let aTemplateList = MTLJSONAdapter.modelsOfClass(TemplateListModel.self, fromJSONArray: json, error: nil) as! [TemplateListModel]
            templateList = aTemplateList
        }
        
    }
    
    func saveTemplateListInfoToLocal() {
        
    }
    
    
}