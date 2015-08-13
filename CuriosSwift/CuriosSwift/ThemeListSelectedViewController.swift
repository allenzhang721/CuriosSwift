//
//  ThemeListSelectedViewController.swift
//  
//
//  Created by Emiaostein on 8/12/15.
//
//

import UIKit

protocol ThemeListSelectedViewControllerDelegate: NSObjectProtocol {
  
  func themeListSelectedViewController(viewcontroller: ThemeListSelectedViewController, DidConfirmThemeID themeID: String)
  
}

class ThemeListSelectedViewController: UIViewController {
  
  weak var delegate: ThemeListSelectedViewControllerDelegate?

  @IBOutlet weak var tableView: UITableView!
  
  var themeList = [ThemeModel]()
  
  @IBOutlet weak var confirmButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
      confirmButton.enabled = false
      ThemesManager.shareInstance.getThemes(true, start: 0, size: 20) {[weak self] (alist) -> () in
        
        if alist.count > 0 {
          self?.appendThemes(alist)
          self?.tableView.reloadData()
        }
      }
    }
  
  private func appendThemes(themes: [ThemeModel]) {
    for theme in themes {
      themeList.append(theme)
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  

  func configCell(cell: UITableViewCell, theme: ThemeModel) {
    
    cell.textLabel?.text = theme.themeName
  }
  
  @IBAction func confirmAction(sender: UIBarButtonItem) {
    
    if let indexPath = tableView.indexPathForSelectedRow() {
      
      let theme = themeList[indexPath.item]
      showAlert(theme)
    }
    
  }
  
  func showAlert(theme: ThemeModel) {
    let themeName = theme.themeName
    let themeID = theme.themeID
    let cancelAction = UIAlertAction(title: "取消", style: .Cancel) { (action) -> Void in
    }
    
    let confirmAcion = UIAlertAction(title: "确定", style: .Default) {[weak self] (action) -> Void in
      self?.delegate?.themeListSelectedViewController(self!, DidConfirmThemeID: themeID)
      self?.navigationController?.popViewControllerAnimated(true)
    }
    
    let alert = UIAlertController(title: "提示", message: "您确定要将模板上传至主题'\(themeName)'吗？", preferredStyle: .Alert)
    alert.addAction(cancelAction)
    alert.addAction(confirmAcion)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
}

extension ThemeListSelectedViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return themeList.count
  }
  
  // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
  // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("ThemeCell") as! UITableViewCell
    
    if themeList.count > 0 {
      let theme = themeList[indexPath.item]
      configCell(cell, theme: theme)
    }
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if !confirmButton.enabled {
      confirmButton.enabled = true
    }
    
  }
  
  
}
