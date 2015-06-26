//
//  BookDetailViewController.swift
//  
//
//  Created by Emiaostein on 6/18/15.
//
//

import UIKit

class BookDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var bookModel: BookModel!
    
//    lazy var iconPath: String = {
//        
//        let userID = UsersManager.shareInstance.getUserID()
//        let bookID = aBookModel.Id
//        let iconPath = aBookModel.icon
//        let url = temporaryDirectory(userID, bookID, iconPath)
//        
//        return ""
//    }()
    
    var icon: UIImage? {
        
        let userID = UsersManager.shareInstance.getUserID()
        
        let bookID = bookModel.Id
        let iconPath = bookModel.icon
        let url = temporaryDirectory(userID, bookID, iconPath)
        println(url)
        let image = UIImage(contentsOfFile: url.path!)
        return image
    }
    
    var background: UIImage? {
        
        let userID = UsersManager.shareInstance.getUserID()
        let bookID = bookModel.Id
        let background = bookModel.background
        let url = temporaryDirectory(userID, bookID, background)
        
        println(url)
        let image = UIImage(contentsOfFile: url.path!)
        return image
    }
    
    var bookTitle: String {
        
        let title = bookModel.title
        return title
    }
    
    var bookDescription: String {
        
        let title = bookModel.desc
        return title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "BookDetailImageCell", bundle: nil), forCellReuseIdentifier: "BookDetailImageCell")
        tableView.registerNib(UINib(nibName: "BookDetailInfoCell", bundle: nil), forCellReuseIdentifier: "BookDetailInfoCell")
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    @IBAction func backAction(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - DataSource and Delegate
// MARK: -

// MARK: - IBAction
// MARK: -

// MARK: - Private Method
// MARK: -
extension BookDetailViewController: UITableViewDataSource, UITableViewDelegate, textInputViewControllerProtocol {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            if row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailImageCell
                cell.titleLabel?.text = NSLocalizedString("BookDetailIcon", comment: "国际化的语言测试")
                println(icon)
                cell.iconImageView?.image = icon
                return cell
            } else if row == 1{
                let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailInfoCell") as! BookDetailInfoCell
                cell.titleLabel?.text = NSLocalizedString("BookDetailTitle", comment: "国际化的语言测试")
                cell.descriText?.text = bookTitle
                return cell
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailInfoCell") as! BookDetailInfoCell
                cell.titleLabel?.text = NSLocalizedString("BookDetailDescri", comment: "国际化的语言测试")
                cell.tableView = tableView
                cell.descriText?.text = bookDescription
                return cell
            }
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("BookDetailImageCell") as! BookDetailImageCell
            cell.titleLabel?.text = NSLocalizedString("BookDetailBackground", comment: "国际化的语言测试")
            cell.iconImageView?.image = background
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            
            if row == 2{
                
                if let aInputVC = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("TextInputViewController") as? TextInputViewController {
                    aInputVC.text = bookModel.desc
                    aInputVC.ID = "Description"
                    aInputVC.delegate = self
                    navigationController?.pushViewController(aInputVC, animated: true)
                }
            } else if row == 1 {
                if let aInputVC = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("TextInputViewController") as? TextInputViewController {
                    aInputVC.text = bookModel.title
                    aInputVC.ID = "Title"
                    aInputVC.delegate = self
                    navigationController?.pushViewController(aInputVC, animated: true)
                }
            }
        }
    }
    
    func textInputViewControllerTextDidEnd(inputViewController: TextInputViewController, text: String) {
        
        if inputViewController.ID == "Description" {
            bookModel.desc = text
        } else if inputViewController.ID == "Title" {
            bookModel.title = text
        }
        
        tableView.reloadData()
    }
    
    
    
    
    
    
    
    
}