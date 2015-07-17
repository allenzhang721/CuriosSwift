//
//  FontsManager.swift
//  Fonts
//
//  Created by Emiaostein on 6/29/15.
//  Copyright (c) 2015 Emiaostein. All rights reserved.
//

import Foundation
import CoreText

struct FontInfo {
    let fontTitle: String
    let fontName: String
}

final class FontsManager {
    
    private var fontsList = [FontInfo]()
    
    let fontsURL = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent("Font")
   static let share = FontsManager()
    
    func registerFontWithURL(url: NSURL) -> Bool {
        
        let fontData = NSData(contentsOfURL: url)
        if fontData == nil {
            return false
        }
        
        let providerRef = CGDataProviderCreateWithCFData(fontData)
        let font = CGFontCreateWithDataProvider(providerRef)
        if CTFontManagerRegisterGraphicsFont(font!, nil) {
            return true
        } else {
            return false
        }
    }
    
    func getFontsList() -> [FontInfo] {
        return fontsList
    }
  
  func getFontNameList() -> [String] {
    
    let names = fontsList.map { (fontInfo) -> String in
      
      return fontInfo.fontName
    }
    
    return names
  }
    
    func registerLocalFonts() {
        
        let fileManger = NSFileManager.defaultManager()
        
//        let entries = fileManger.enumeratorAtURL(fontsURL, includingPropertiesForKeys: nil, options: [.SkipsPackageDescendants, .SkipsHiddenFiles]) { (url, error) -> Bool in
//            return true
//        }
        
        let entries = fileManger.enumeratorAtURL(fontsURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions(0)) { (url, error) -> Bool in
            return true
        }
        
        while let url = entries?.nextObject() as? NSURL {
            
            var flag = ObjCBool(false)
            fileManger.fileExistsAtPath(url.path!, isDirectory: &flag)
            if flag.boolValue == false {
                // file that is not directory
                if url.pathExtension == "info" {
                    
                    let infoData = NSData(contentsOfURL: url)
                    let json = NSJSONSerialization.JSONObjectWithData(infoData!, options: NSJSONReadingOptions(0), error: nil) as! [String: String]
                    
                    let dir = json["fileDIR"]
                    let name = json["fileName"]
                    let fontURL = fontsURL.URLByAppendingPathComponent(dir!).URLByAppendingPathComponent(name!)
                    if registerFontWithURL(fontURL) {
                        let title = json["fontTitle"]!
                        let name = json["regularName"]!
                        let aFontInfo = FontInfo(fontTitle: title, fontName: name)
                        fontsList.append(aFontInfo)
                    }
                }
            }
        }
    }
}