//
//  OfflineRecognitionViewController.swift
//  Handwritten Digit Recognition
//
//  Created by Tadeh Alexani on 3/21/20.
//  Copyright © 2020 Alexani. All rights reserved.
//

import UIKit
import Vision

class OfflineRecognitionViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  let notificationGenerator = UINotificationFeedbackGenerator()
  let impactGenerator = UIImpactFeedbackGenerator(style: .light)
  let showResultsSegue = "showResults"
  
  var result: Int64 = 0
  var proba = [Int64 : Double]()
  var selectedImg = UIImage()
  
  @IBAction func cameraBtnTapped(_ sender: Any) {
    impactGenerator.impactOccurred()
    presentCamera()
  }
  
  @IBAction func libraryBtnTapped(_ sender: Any) {
    impactGenerator.impactOccurred()
    presentLibrary()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  func presentCamera() {
    let vc = UIImagePickerController()
    vc.sourceType = .camera
    vc.allowsEditing = true
    vc.delegate = self
    present(vc, animated: true)
  }
  
  func presentLibrary() {
    let vc = UIImagePickerController()
    vc.sourceType = .photoLibrary
    vc.allowsEditing = true
    vc.delegate = self
    present(vc, animated: true)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)
    
    guard let image = info[.editedImage] as? UIImage else {
      print("No image found")
      return
    }
    
    // Play with contrast number
    guard let coreImage = image.coreImage,
      let grayscale = coreImage.grayscale,
      let increasedContrast = grayscale.applying(contrast: 20),
      let uiImg = increasedContrast.uiImage
      else {
        print("Error converting photo")
        return
    }

    let resizedImg = uiImg.resized(to: CGSize(width: 32, height: 32))
    selectedImg = resizedImg
    recognizeWithLocalModel(resizedImg)
  }
  
  func generateMultiArrayFrom(image: UIImage) -> MLMultiArray? {
    guard let data = try? MLMultiArray(shape: [32,32], dataType: .double) else {
      return nil
    }
    
    let pixelColors = image.getPixels()
    
    for (idx,color) in pixelColors.enumerated() {
      var grayscale: CGFloat = 0
      var alpha: CGFloat = 0
      
      color.getWhite(&grayscale, alpha: &alpha)
      
      if grayscale == 0.0 {
        data[idx] = 1.0
      } else {
        data[idx] = 0.0
      }
      
    }
    
    return data
  }
  
  func recognizeWithLocalModel(_ image: UIImage) {
    if let data = generateMultiArrayFrom(image: image) {
      guard let modelOutput = try? SklearnModel().prediction(input: data) else {
        return
      }
            
      if let result = modelOutput.classLabel as Int64?, let proba = modelOutput.classProbability as [Int64 : Double]? {
        notificationGenerator.notificationOccurred(.success)
        self.proba = proba
        self.result = result
        performSegue(withIdentifier: showResultsSegue, sender: nil)
      } else {
        notificationGenerator.notificationOccurred(.error)
        print("no result available")
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == showResultsSegue) {
      guard let destVC = segue.destination as? ResultsViewController else { return }
      destVC.image = selectedImg
      destVC.proba = proba
      destVC.result = result
    }
  }
  
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
}
