//
//  TextInputViewController.swift
//
//
//  Created by Emiaostein on 6/24/15.
//
//

import UIKit

protocol textInputDataSource: NSObjectProtocol {
  
  func textofTextInputController(inputViewController: UIViewController) -> String
  
   func textInputViewControllerTextDidChanged(inputViewController: UIViewController, didChangedText aText: String)
}

protocol textInputViewControllerProtocol: NSObjectProtocol {
  
  func textInputViewControllerTextDidEnd(inputViewController: TextInputViewController, text: String)
  //    func textInputViewControllerTextDidEnd(text: String)
}

class TextInputViewController: UIViewController {
  
  let TextInputTypeTitleName = "Title"
  let TextInputTypeContentName = "Content"
  
  var type = ""
  
  var text = ""
  var ID = ""
  weak var delegate: textInputViewControllerProtocol?
  @IBOutlet weak var textView: UITextView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if type == TextInputTypeTitleName {
      
      setupTitleVC()
      
    } else if type == TextInputTypeContentName {
      
      setupContentVC()
    }
//    
//    textView.text = text
  }
  
  func setupTitleVC() {
    
    
    if let titleInput = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("TextInputTitleViewController") as? TextInputTitleViewController {
      titleInput.dataSource = self
      addChildViewController(titleInput)
      titleInput.view.bounds = view.bounds
      view.addSubview(titleInput.view)
    }

  }
  
  func setupContentVC() {
    //TextInputContentViewController
    if let Input = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("TextInputContentViewController") as? TextInputContentViewController {
      Input.dataSource = self
      addChildViewController(Input)
      Input.view.bounds = view.bounds
      view.addSubview(Input.view)
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    
    if let aDelegate = delegate {
      aDelegate.textInputViewControllerTextDidEnd(self, text:text)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension TextInputViewController: textInputDataSource {
  
  func textInputViewControllerTextDidChanged(inputViewController: UIViewController, didChangedText aText: String) {
    
    text = aText
  }
  
  func textofTextInputController(inputViewController: UIViewController) -> String {
    
    return text
  }
}

