//
//  RegisterInfoViewController.swift
//  
//
//  Created by Emiaostein on 8/18/15.
//
//

import UIKit

class RegisterInfoViewController: UIViewController {

  
  @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  func configCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    
    switch (indexPath.section, indexPath.row) {
      
    case (0, 0):
      let cell = tableView.dequeueReusableCellWithIdentifier("IconCell") as! UITableViewCell
      if let iconView = cell.viewWithTag(1000) as? UIImageView {
        
      }
      
      return cell
    case (1, 0):
      let cell = tableView.dequeueReusableCellWithIdentifier("NicknameCell") as! UITableViewCell
      if let textfield = cell.viewWithTag(1001) as? UITextField {
        
      }
      
      return cell
      
    default:
      return tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    }
  }

}

extension RegisterInfoViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    switch (indexPath.section, indexPath.row) {
    case(0, 0):
      return 108
    default:
      return 44
    }
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    return configCell(tableView, indexPath: indexPath)
  }
  
}