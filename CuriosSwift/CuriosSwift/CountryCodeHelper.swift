//
//  CountryCodeHelper.swift
//  CuriosSwift
//
//  Created by Emiaostein on 8/17/15.
//  Copyright (c) 2015 botai. All rights reserved.
//

import Foundation

class  CountryCodeHelper {
  
 static let defaultCodes = ["IM":"44", "HR":"385", "GW":"245", "IN":"91", "KE":"254", "LA":"856", "IO":"246", "HT":"509", "GY":"595", "LB":"961", "KG":"996", "HU":"36", "LC":"1", "IQ":"964", "KH":"855", "JM":"1", "IR":"98", "KI":"686", "IS":"354", "MA":"212", "JO":"962", "IT":"39", "JP":"81", "MC":"377", "KM":"269", "MD":"373", "LI":"423", "KN":"1", "ME":"382", "NA":"264", "MF":"590", "LK":"94", "KP":"850", "MG":"261", "NC":"687", "MH":"692", "KR":"82", "NE":"227", "NF":"672", "MK":"389", "NG":"234", "ML":"223", "MM":"95", "LR":"231", "NI":"505", "KW":"965", "MN":"976", "LS":"266", "PA":"507", "MO":"853", "LT":"370", "KY":"345", "MP":"1", "LU":"352", "NL":"31", "KZ":"77", "MQ":"596", "LV":"371", "MR":"222", "PE":"51", "MS":"1", "QA":"974", "NO":"47", "PF":"689", "MT":"356", "LY":"218", "NP":"977", "PG":"675", "MU":"230", "PH":"63", "MV":"960", "OM":"968", "NR":"674", "MW":"265", "MX":"52", "PK":"92", "MY":"60", "NU":"683", "PL":"48", "MZ":"258", "PM":"508", "PN":"872", "RE":"262", "SA":"966", "SB":"677", "NZ":"64", "SC":"248", "SD":"249", "PR":"1", "SE":"46", "PS":"970", "PT":"351", "SG":"65", "TC":"1", "SH":"290", "TD":"235", "SI":"386", "PW":"680", "SJ":"47", "UA":"380", "RO":"40", "SK":"421", "PY":"595", "TG":"228", "SL":"232", "TH":"66", "SM":"378", "SN":"221", "RS":"381", "TJ":"992", "VA":"379", "SO":"252", "TK":"690", "UG":"256", "RU":"7", "TL":"670", "VC":"1", "TM":"993", "SR":"597", "RW":"250", "TN":"216", "VE":"58", "TO":"676", "ST":"239", "VG":"1", "SV":"503", "TR":"90", "VI":"1", "WF":"681", "TT":"1", "SY":"963", "SZ":"268", "TV":"688", "TW":"886", "VN":"84", "US":"1", "TZ":"255", "YE":"967", "ZA":"27", "UY":"598", "VU":"678", "UZ":"998", "WS":"685", "ZM":"260", "AD":"376", "YT":"262", "AE":"971", "BA":"387", "AF":"93", "BB":"1", "AG":"1", "BD":"880", "AI":"1", "BE":"32", "CA":"1", "BF":"226", "BG":"359", "ZW":"263", "AL":"355", "CC":"61", "BH":"973", "AM":"374", "CD":"243", "BI":"257", "AN":"599", "BJ":"229", "AO":"244", "CF":"236", "CG":"242", "BL":"590", "CH":"41", "BM":"1", "AR":"54", "CI":"225", "BN":"673", "DE":"49", "AS":"1", "BO":"591", "AT":"43", "CK":"682", "AU":"61", "CL":"56", "EC":"593", "CM":"237", "BR":"55", "AW":"297", "CN":"86", "EE":"372", "BS":"1", "DJ":"253", "CO":"57", "BT":"975", "DK":"45", "EG":"20", "AZ":"994", "DM":"1", "CR":"506", "BW":"267", "GA":"241", "DO":"1", "BY":"375", "GB":"44", "CU":"53", "BZ":"501", "CV":"238", "GD":"1", "FI":"358", "GE":"995", "FJ":"679", "CX":"61", "GF":"594", "FK":"500", "CY":"537", "GG":"44", "CZ":"420", "GH":"233", "FM":"691", "ER":"291", "GI":"350", "ES":"34", "FO":"298", "ET":"251", "GL":"299", "DZ":"213", "GM":"220", "ID":"62", "FR":"33", "GN":"224", "IE":"353", "HK":"852", "GP":"590", "GQ":"240", "GR":"30", "HN":"504", "JE":"44", "GS":"500", "GT":"502", "GU":"1", "IL":"972"]
  
  class func codeByCountry(contryCode: String) -> String? {
    return defaultCodes[contryCode]
  }
  
  class func numberOfCountries() -> Int {
    return defaultCodes.count
  }
  
  class func currentCountryDisplayNameAreaCodeCountryCode() -> (String, String, String) {
    let local = NSLocale.currentLocale()
    let countryCode = local.objectForKey(NSLocaleCountryCode) as! String
    let areaCode = CountryCodeHelper.defaultCodes[countryCode]
    let countryName = local.displayNameForKey(NSLocaleCountryCode, value: countryCode)
    return (countryName!, areaCode!, countryCode)
  }
  
  /*
  {
  rule = "[0-9]{10}";
  zone = 1;
  }
  */
  
  class func getVerificationCodeBySMSWithPhone(phone: String, zoneCode: String, compelted:(Bool) -> ()) {
    
    SMS_SDK.getVerificationCodeBySMSWithPhone(phone, zone: zoneCode) { (error) -> Void in
      
      if error == nil {
        debugPrint.p("验证码发送成功")
        compelted(true)
      } else {
        compelted(false)
      }
    }
    
  }
  
  class func commit(verifyCode: String, compelted:(Bool) -> ()) {
    
    SMS_SDK.commitVerifyCode(verifyCode, result: { (state) -> Void in
      
      if state.value == 1 {
        compelted(true)
      } else {
        compelted(false)
      }
    })
  }
  
  
  
  struct Zone {
    let zoneCode: String   // 86
    let phoneCheckRule: String //
  }
  
  class func getZone(completed:(Bool, [Zone]) -> ()) {
    SMS_SDK.getZone { (state, array) -> Void in
      if state.value == 1 {
        debugPrint.p("get the area code sucessfully")
        
        let zones = array.map({ (zoneDic) -> Zone in
          let zoneCode = zoneDic["zone"] as! String
          let rule = zoneDic["rule"] as! String
          return Zone(zoneCode: zoneCode, phoneCheckRule: rule)
        })
        
        completed(true, zones)
      } else {
        completed(false, [Zone]())
      }
    }
  }
  
//  class func checkZoneBy(zoneCode: String, phone: String, toTargetZone zone: Zone) -> Bool {
//    
//    
//  }
  
}