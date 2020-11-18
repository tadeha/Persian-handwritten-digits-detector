//
//  ResultsViewController.swift
//  Handwritten Digit Recognition
//
//  Created by Tadeh Alexani on 3/22/20.
//  Copyright © 2020 Alexani. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
  
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var resultLabel: UILabel!
  @IBOutlet weak var probaLabel: UILabel!
  
  var result: Int64 = 0
  var proba = [Int64 : Double]()
  var image = UIImage()
  
  @IBAction func doneBtnTapped(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let sortedDict = proba.sorted(by: { $0.0 < $1.0 })
    let probaArr = (sortedDict.compactMap({ (key, value) -> String in
        return "\(key) = \(Int(value))%"
    }) as Array).joined(separator: "\n")
    
    imgView.image = image
    resultLabel.text = "\(result)"
    probaLabel.text = "\(probaArr)"
  }
  
  
}
