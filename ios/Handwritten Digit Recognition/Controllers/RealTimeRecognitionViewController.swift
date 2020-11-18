//
//  RealTimeRecognitionViewController.swift
//  Handwritten Digit Recognition
//
//  Created by Tadeh Alexani on 3/31/20.
//  Copyright © 2020 Alexani. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class RealTimeRecognitionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
  // create a label to hold the Number definition and confidence
  let label: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "-"
    label.font = UIFont(name: "Dana-FaNum-DemiBold", size: 48)
    return label
  }()
  
  var bufferSize: CGSize = .zero
  
  private let session = AVCaptureSession()
  private var previewLayer: AVCaptureVideoPreviewLayer! = nil
  private let videoDataOutput = AVCaptureVideoDataOutput()
  
  override func viewDidLoad() {
    // call the parent function
    super.viewDidLoad()
    view.backgroundColor = .black
    startCaptureSession() // establish the capture
    view.addSubview(label) // add the label
    setupLabel()
  }
  
  @IBAction func closeBtnTapped(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
  
  func startCaptureSession() {
    
    var deviceInput: AVCaptureDeviceInput!
    
    let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    do {
      deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
    } catch {
      print("Could not create video device input: \(error)")
      return
    }
    
    session.beginConfiguration()
    session.sessionPreset = .vga640x480 // Model image size is smaller.
    
    guard session.canAddInput(deviceInput) else {
      print("Could not add video device input to the session")
      session.commitConfiguration()
      return
    }
    session.addInput(deviceInput)
    
    if session.canAddOutput(videoDataOutput) {
      session.addOutput(videoDataOutput)
      // Add a video data output
      videoDataOutput.alwaysDiscardsLateVideoFrames = true
      videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
      videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
    } else {
      print("Could not add video data output to the session")
      session.commitConfiguration()
      return
    }
    
    let captureConnection = videoDataOutput.connection(with: .video)
    // Always process the frames
    captureConnection?.isEnabled = true
    do {
      try  videoDevice!.lockForConfiguration()
      let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
      bufferSize.width = CGFloat(dimensions.width)
      bufferSize.height = CGFloat(dimensions.height)
      videoDevice!.unlockForConfiguration()
    } catch {
      print(error)
    }
    
    session.commitConfiguration()
    
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.frame = view.frame
    view.layer.addSublayer(previewLayer)
    
    session.startRunning()
    
  }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    // load our CoreML model
    guard let model = try? VNCoreMLModel(for: KerasModel().model) else {
      return }
    
    // run an inference with CoreML
    let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
      
      // grab the inference results
      guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
      
      // print(results)
      
      // grab the highest confidence result
      guard let Observation = results.first else { return }
      
      // create the label text components
      let predclass = "\(Observation.identifier)"
      
      // set the label text
      DispatchQueue.main.async(execute: {
        self.label.text = "\(predclass) "
      })
    }
    
    // create a Core Video pixel buffer which is an image buffer that holds pixels in main memory
    // Applications generating frames, compressing or decompressing video, or using Core Image
    // can all make use of Core Video pixel buffers
    
    guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    
    // execute the request
    // https://stackoverflow.com/questions/44688552/ios-vision-vnimagerequesthandler-orientation-issue
    try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:]).perform([request])
  }
  
  func setupLabel() {
    // constrain the label in the center
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    // constrain the the label to 50 pixels from the bottom
    label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
  }
}
