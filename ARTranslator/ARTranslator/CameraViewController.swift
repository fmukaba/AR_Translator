//
//  CameraViewController.swift
//  ARTranslator
//
//  Created by Francois Mukaba on 2/5/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)

        if (captureDevice != nil){
            beginSession()
            //startTextDetection()
        } else {
            // Tell user they need a back-camera before using app
            presentAlert(title: "Error", message: "No back-camera was found.")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTextDetection()
    }

    func beginSession() {
        captureSession.beginConfiguration()
        
        // get camera capture
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput)
        else { return }
        captureSession.addInput(videoDeviceInput)
        
        // output camera-feed on screen
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        captureSession.addOutput(deviceOutput)
        
        // add a sublayer containing the video preview to the imageView
        let imageLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        // start session
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    func startTextDetection() {
        
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        textRequest.reportCharacterBoxes = true
        
        requests = [textRequest, request]
        
    }
    // Handler for text itself
    fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            presentAlert(title: "Error", message: error.localizedDescription)
            return
        }
        guard let results = request?.results, results.count > 0 else {
            presentAlert(title: "Error", message: "No text was found.")
            return
        }

       
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    print(text.string)
                }
            }
        }
        
       
        
        
    }
    
    
    // Handler for bounding boxes
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no result")
            return
        }
            
        let result = observations.map({$0 as? VNTextObservation})
        DispatchQueue.main.async() {
            self.imageView.layer.sublayers?.removeSubrange(1...)
            for region in result {
                
                guard let rg = region else {
                    continue
                }
                
                self.highlightWord(box: rg)
                
//                if let boxes = region?.characterBoxes {
//                    for characterBox in boxes {
//                        self.highlightLetters(box: characterBox)
//                    }
//                }
            }
        }
    }
    
    func highlightWord(box: VNTextObservation) {
        guard let boxes = box.characterBoxes else {
            return
        }
            
        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0
            
        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }
            
        let xCord = maxX * imageView.frame.size.width
        let yCord = (1 - minY) * imageView.frame.size.height
        let width = (minX - maxX) * imageView.frame.size.width
        let height = (minY - maxY) * imageView.frame.size.height
            
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
            
        imageView.layer.addSublayer(outline)
    }
    
    fileprivate func presentAlert(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
}
