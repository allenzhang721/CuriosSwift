//
//  GenerateTemplateViewController.swift
//  
//
//  Created by Emiaostein on 8/12/15.
//
//

import UIKit

protocol GenerateTemplateViewControllerDataSource: NSObjectProtocol {
  
  func generateTemplateViewControllerPageTitle(ViewController: GenerateTemplateViewController) -> String
  
  func generateTemplateViewControllerPageDescription(ViewController: GenerateTemplateViewController) -> String
  
  func generateTemplateViewControllerPublishID(ViewController: GenerateTemplateViewController) -> String
  
  func generateTemplateViewControllerPageID(ViewController: GenerateTemplateViewController) -> String
  
  func generateTemplateViewControllerPageBackgroundColorWithHex(ViewController: GenerateTemplateViewController) -> String
  
  func generateTemplateViewControllerPageAlpha(ViewController: GenerateTemplateViewController) -> Float
  
  func generateTemplateViewControllerPageSnapshot(ViewController: GenerateTemplateViewController) -> UIImage
  
  func generateTemplateViewController(ViewController: GenerateTemplateViewController, didChangedTitle pageTitle: String)
  
  func generateTemplateViewController(ViewController: GenerateTemplateViewController, didChangedDescri pageDescri: String)
  
  func generateTemplateViewController(ViewController: GenerateTemplateViewController, didChangedBackgroundColor colorHex: String)
  
  func generateTemplateViewController(ViewController: GenerateTemplateViewController, didChangedBackAlpha Alpha: CGFloat)
  
  func generateTemplateViewControllerChangedPageJsonData(ViewController: GenerateTemplateViewController) -> NSData
  
}

class GenerateTemplateViewController: UIViewController {
  
  weak var dataSource: GenerateTemplateViewControllerDataSource?
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var descriTextField: UITextField!
  @IBOutlet weak var colorPickerCollectionView: UICollectionView!
  @IBOutlet weak var alphaSlider: UISlider!
  @IBOutlet weak var alphaLabel: UILabel!
  
  let uploader = UploadsManager()
  
  var originPageTitle: String! {
    return dataSource?.generateTemplateViewControllerPageTitle(self)
  }
  
  var originPageDescr: String! {
    return dataSource?.generateTemplateViewControllerPageDescription(self)
  }
  
  var originAlpha: Float! {
    return dataSource?.generateTemplateViewControllerPageAlpha(self)
  }
  
  var originColor: String! {
    return dataSource?.generateTemplateViewControllerPageBackgroundColorWithHex(self)
  }
  
  var pageSnapShot: UIImage! {
    return dataSource?.generateTemplateViewControllerPageSnapshot(self)
  }
  
  var colors: [String] {
    return ColorManager.shareInstance.defaultColors
  }
  
  var pageID: String! {
    return dataSource?.generateTemplateViewControllerPageID(self)
  }
  
  var publishID: String! {
    return dataSource?.generateTemplateViewControllerPublishID(self)
  }
  
  var currentColor: String! {
    
    let indexPath = colorPickerCollectionView.indexPathsForSelectedItems()[0] as! NSIndexPath
    return colors[indexPath.item]
  }
  
  var currentAlpha: Float {
    return (Float(Int(alphaSlider.value * 10))/10)
  }
  

    override func viewDidLoad() {
        super.viewDidLoad()
      
//      begainSetup()

        // Do any additional setup after loading the view.
    }
  

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
      if let themelistVC = segue.destinationViewController as? ThemeListSelectedViewController {
        
        themelistVC.delegate = self
      }
    }

  
  @IBAction func closeAction(sender: UIBarButtonItem) {
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func sliderValueDidChanged(sender: UISlider) {
    alphaLabel.text = "\(currentAlpha)"
    if originAlpha != currentAlpha {
        dataSource?.generateTemplateViewController(self, didChangedBackAlpha: CGFloat(currentAlpha))
    }
  }
  
  func begainUpload(themeID: String, pagejsonData: NSData, completed: (Bool) -> ()) {

    // templateID
    GetTemplateIDRequest.requestWithComponents(GET_TEMPLATEID, aJsonParameter: nil) {[weak self] (json) -> Void in
      
      if let templateID = json["newID"] as? String {
        
        // upload snapshot
        self?.uploadSnapshot(templateID)
        
        // upload json
        self?.uploadPageJson(pagejsonData)
        
        // uploadself
        self?.setUploadCompleted(templateID, themeID: themeID, completed: { (finished) -> () in
          completed(finished)
        })
      } else {
        completed(true)
      }
    }.sendRequest()
  }
  
  func setUploadCompleted(templateID: String, themeID: String, completed: (Bool) -> ()) {
    
    uploader.setCompeletedHandler {[weak self] (finished, hasError) -> () in
      
      // add template
      self?.begainAddTemplate(templateID, themeID: themeID, completed: { (finished) -> () in
        completed(finished)
      })
    }
  }
  
  func begainAddTemplate(templateID:String, themeID: String, completed: (Bool) -> ()) {
    
    let userID = UsersManager.shareInstance.getUserID()
    let templateURL = pathByComponents([userID, publishID, pageID, "page.json"])
    let templateIconURL = pathByComponents([templateID, "icon.png"])
    let templateName = nameTextField.text
    let tempaltedes = descriTextField.text
    
    let para = ADD_TEMPLATE_paras(authorID: userID, templateID, templateURL, templateIconURL, templateName, tempaltedes, templatePayType: 0, templatePrice: 0.0, themeID)
    AddTemplateRequest.requestWithComponents(ADD_TEMPLATE, aJsonParameter: para) { (json) -> Void in
      completed(true)
    }.sendRequest()
    
  }
  
  func uploadSnapshot(templateID: String) {
    
    //key
    let imageData = UIImagePNGRepresentation(pageSnapShot)
    let imagekey = pathByComponents([templateID, "icon.png"])
    // upload snapshot
    prepareUploadImageData(imageData, key: imagekey) { [weak self] (imageData, key, token) -> () in
      self?.uploader.upload([imageData], keys: [key], tokens: [token])
    }
  }
  
  func uploadPageJson(pagejsonData: NSData) {
    let userID = UsersManager.shareInstance.getUserID()
    let key = pathByComponents([userID, publishID, pageID, "page.json"])
    let apageData =  pagejsonData
//    // upload snapshot
//    
    prepareUploadImageData(apageData, key: key) { [weak self] (pageData, key, token) -> () in
      self?.uploader.upload([pageData], keys: [key], tokens: [token])
    }
  }
  
  func prepareUploadImageData(data: NSData, key: String, compeletedBlock:(NSData, String, String) -> ()) {
    let json = GET_TEMPLATEUPTOKEN_paras(key)
    
    ImageTokenRequest.requestWithComponents(GET_TEMPLATEUPTOKEN, aJsonParameter: json) { (json) -> Void in
      
      if let keyTokens = json["list"] as? [[String:String]] {
        
        let keyToken = keyTokens[0]
        let token = keyToken["upToken"]!
        
        compeletedBlock(data, key, token)
      }
      }.sendRequest()
  }
  
  
  func hexToRgb(hexString: String) -> String {
    
    var hex = hexString
    
    // Check for hash and remove the hash
    if hex.hasPrefix("#") {
      hex = hex.substringFromIndex(advance(hex.startIndex, 1))
    }
    
    if let match = hex.rangeOfString("(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) {
      
      // Deal with 3 character Hex strings
      if count(hex) == 3 {
        var redHex   = hex.substringToIndex(advance(hex.startIndex, 1))
        var greenHex = hex.substringWithRange(Range<String.Index>(start: advance(hex.startIndex, 1), end: advance(hex.startIndex, 2)))
        var blueHex  = hex.substringFromIndex(advance(hex.startIndex, 2))
        
        hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
      }
      
      let redHex = hex.substringToIndex(advance(hex.startIndex, 2))
      let greenHex = hex.substringWithRange(Range<String.Index>(start: advance(hex.startIndex, 2), end: advance(hex.startIndex, 4)))
      let blueHex = hex.substringWithRange(Range<String.Index>(start: advance(hex.startIndex, 4), end: advance(hex.startIndex, 6)))
      
      var redInt:   CUnsignedInt = 0
      var greenInt: CUnsignedInt = 0
      var blueInt:  CUnsignedInt = 0
      
      NSScanner(string: redHex).scanHexInt(&redInt)
      NSScanner(string: greenHex).scanHexInt(&greenInt)
      NSScanner(string: blueHex).scanHexInt(&blueInt)
      
      return "\(redInt),\(greenInt),\(blueInt)"
    } else {
      return "255,255,255"
    }
  }
}

extension GenerateTemplateViewController: ThemeListSelectedViewControllerDelegate {
  
  func themeListSelectedViewController(viewcontroller: ThemeListSelectedViewController, DidConfirmThemeID themeID: String) {
    
    // themeID, 
    if originPageTitle != nameTextField.text {
      dataSource?.generateTemplateViewController(self, didChangedTitle: nameTextField.text)
    }
    
    if originPageDescr != descriTextField.text {
      dataSource?.generateTemplateViewController(self, didChangedDescri: descriTextField.text)
    }
    
//    if originColor != currentColor {
//      let rgb = hexToRgb(currentColor)
//      dataSource?.generateTemplateViewController(self, didChangedBackgroundColor: rgb)
//    }
    
//    if originAlpha != currentAlpha {
//      dataSource?.generateTemplateViewController(self, didChangedBackAlpha: CGFloat(currentAlpha))
//    }
    
    if let pagejsonData = dataSource?.generateTemplateViewControllerChangedPageJsonData(self) {
      
      HUD.preview_upload()
      begainUpload(themeID, pagejsonData: pagejsonData, completed: {[weak self] (completed) -> () in
        
        HUD.dismiss()
        self?.dismissViewControllerAnimated(true, completion: nil)
      })
    }
  }
    
    override func viewDidAppear(animated: Bool) {
        begainSetup()
    }
}

extension GenerateTemplateViewController {
  
  func begainSetup() {
    
    // title
    nameTextField.text = originPageTitle
    // des
    descriTextField.text = originPageDescr
    
    // color picker
    colorPickerCollectionView.delegate = self
    colorPickerCollectionView.dataSource = self
    colorPickerCollectionView.allowsSelection = true
    let index = (colors as NSArray).indexOfObject(originColor)
    if index >= 0 && index < colors.count {
      colorPickerCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
    } else {
      colorPickerCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
    }
    // slider & label
    alphaSlider.value = originAlpha
    alphaLabel.text = "\(originAlpha)"
    
  }
  
  func configCell(cell: UICollectionViewCell, color: String) {
    
    let aColor = UIColor(hexString: color)
    if cell.backgroundView == nil {
      let aView = UIView(frame: cell.bounds)
      cell.backgroundView = aView
    }
    
    if !(cell.selectedBackgroundView is UIImageView) {
      let image = CuriosKit.imageOfSelectedTick(frame: cell.bounds)
      cell.selectedBackgroundView = UIImageView(image: image)
    }
    
    cell.backgroundView!.backgroundColor = aColor
  }
  
}

extension GenerateTemplateViewController: UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return colors.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath) as! UICollectionViewCell
    let color = colors[indexPath.item]
    configCell(cell, color: color)
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    if originColor != currentColor {
        let rgb = hexToRgb(currentColor)
        dataSource?.generateTemplateViewController(self, didChangedBackgroundColor: rgb)
    }
    
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
  }
}
