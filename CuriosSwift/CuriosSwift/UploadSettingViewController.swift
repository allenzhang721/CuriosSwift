//
//  UploadSettingViewController.swift
//  CuriosSwift
//
//  Created by Emiaostein on 6/26/15.
//  Copyright © 2015 botai. All rights reserved.
//

import UIKit

protocol UploadSettingViewControllerProtocol: NSObjectProtocol {
    
    func uploadSettingViewControllerGetThumbImagePath(controller: UploadSettingViewController) -> String
    func uploadSettingViewControllerGetTitle(controller: UploadSettingViewController) -> String
    func uploadSettingViewControllerGetdescription(controller: UploadSettingViewController) -> String
    func uploadSettingViewControllerDidSettingFinished(controller: UploadSettingViewController, aTitle: String, aDescription: String)
}

class UploadSettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: UploadSettingViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let aDelegate = delegate {
            
            let imagePath = aDelegate.uploadSettingViewControllerGetThumbImagePath(self)
            let bookTitle = aDelegate.uploadSettingViewControllerGetTitle(self)
            let bookDescr = aDelegate.uploadSettingViewControllerGetdescription(self)
            
            let image = UIImage(contentsOfFile: imagePath)
            imageView.image = image
            titleTextField.text = bookTitle
            textView.text = bookDescr
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func confirmAction(sender: UIBarButtonItem) {
        
        if let aDelegate = delegate {
            aDelegate.uploadSettingViewControllerDidSettingFinished(self, aTitle: titleTextField.text, aDescription: textView.text)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
