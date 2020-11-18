//
//  CIImage+Extension.swift
//  Handwritten Digit Recognition
//
//  Created by Tadeh Alexani on 3/22/20.
//  Copyright © 2020 Alexani. All rights reserved.
//

import UIKit

extension CIImage {
  
  var uiImage: UIImage? { return UIImage(ciImage: self) }
  var grayscale: CIImage? { return applying(saturation: 0) }
  
  func applying(contrast value: NSNumber) -> CIImage? {
    return applyingFilter(.colorControls, parameters: [kCIInputContrastKey: value])
  }
  
  func applying(saturation value: NSNumber) -> CIImage? {
    return applyingFilter(.colorControls, parameters: [kCIInputSaturationKey: value])
  }
  
  func renderedImage() -> UIImage? {
    guard let image = uiImage else { return nil }
    return UIGraphicsImageRenderer(size: image.size,
                                   format: image.imageRendererFormat).image { _ in
                                    image.draw(in: CGRect(origin: .zero, size: image.size))
    }
  }
  
}
