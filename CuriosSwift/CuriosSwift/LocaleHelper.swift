//
//  LocaleHelper.swift
//  CountryFilter
//
//  Created by Emiaostein on 15/8/25.
//  Copyright (c) 2015年 BoTai Technology. All rights reserved.
//

import Foundation

struct CountryLocale {
  
  let displayName: String
  let countryCode: String
  let languageCode: String
  let transformLatin: String
  let initialWord: String
  
}

struct CountryZone {
  let displayName: String
  let zoneCode: String
  let transiformLatin: String
}

 func transfromStringToLatin(string: String) -> String {
  let transformContents = CFStringCreateMutableCopy(nil, 0, string)
  CFStringTransform(transformContents, nil, kCFStringTransformToLatin, 0)
  let traStr:String = transformContents as String
  return traStr
}

class LocaleHelper {
  
  static func transformCountryDisplayNameToLatin(countryName: String) -> String {
    return transfromStringToLatin(countryName)
  }
  
  class func allCountriesFromLocalFile() -> Dictionary<String, Array<CountryZone>> {
    
    let countriesFilePath = NSBundle.mainBundle().pathForResource("country", ofType: "plist")!
    var dic = NSDictionary(contentsOfFile: countriesFilePath) as! Dictionary<String, Array<String>>
    
    var con = Dictionary<String, Array<CountryZone>>()
    for (key, countries) in dic {
      let sortCountries = countries.sorted(<)
      let countryZones = sortCountries
          
          .map { string -> CountryZone in
        let component = string.componentsSeparatedByString("+")
        let name = component.first!
        let zoneCode = component.last!
        let latin = self.transformCountryDisplayNameToLatin(name)
        return CountryZone(displayName: name, zoneCode: zoneCode, transiformLatin: latin)
      }
      con[key] = countryZones
    }
    return con
  }
  
  class func AllCountryLocale() -> [CountryLocale] {
  
    let localIdentifiers = NSLocale.availableLocaleIdentifiers() as! [String]
    
    let countryLocales = localIdentifiers
      
  .filter { indentifier -> Bool in
      let compoent = NSLocale.componentsFromLocaleIdentifier(indentifier)
      let countryCode = compoent["kCFLocaleCountryCodeKey"] as? String
      return (countryCode?.isEmpty != nil)
    }
  .map { identifer -> CountryLocale in
      let compoent = NSLocale.componentsFromLocaleIdentifier(identifer)
      let countryCode = compoent["kCFLocaleCountryCodeKey"] as! String
      let languageCode = compoent["kCFLocaleLanguageCodeKey"] as? String ?? ""
      let otherLocal = NSLocale(localeIdentifier: identifer)
      let displayName =  otherLocal.displayNameForKey(NSLocaleCountryCode, value: countryCode)!
      let latin = self.transformCountryDisplayNameToLatin(displayName)
      let index = advance(latin.startIndex, 1)
      let initialWord = latin.uppercaseString.substringToIndex(index)
      return CountryLocale(displayName: displayName, countryCode: countryCode, languageCode: languageCode, transformLatin: latin, initialWord: initialWord)
  }
    
    return countryLocales
  }
}