//
//  ViewController.swift
//  test
//
//  Created by Francois Mukaba on 2/11/20.
//  Copyright © 2020 Francois Mukaba. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate{

    @IBOutlet weak var sceneView: ARSCNView!
    

    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        //sceneView.preferredFramesPerSecond = 2
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
       // sceneView.scene = scene
        requestVisionDetection()
    }
    
 
    
    func requestVisionDetection() {
      
        let request = VNRecognizeTextRequest(completionHandler: self.textDetectionHandler)
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.5
        request.usesCPUOnly = true
        //request.regionOfInterest = region
        requests = [request]
    }
    
    
    // handles request for detected texts
    fileprivate func textDetectionHandler(request: VNRequest?, error: Error?) {
           if let error = error {
               presentAlert(title: "Error", message: error.localizedDescription)
               return
           }
           guard let results = request?.results, results.count > 0 else {
               //presentAlert(title: "Error", message: "No text was found.")
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
        func detectedBoundsHandler(request: VNRequest, error: Error?) {
            guard let observations = request.results else {
                print("no result")
                return
            }
                
            let result = observations.map({$0 as? VNTextObservation})
            DispatchQueue.main.async() {
                self.sceneView.layer.sublayers?.removeSubrange(1...)
                for region in result {
                    
                    guard let rg = region else {
                        continue
                    }
                    
                    self.highlightWord(box: rg, translation : "text")
                    
    //                if let boxes = region?.characterBoxes {
    //                    for characterBox in boxes {
    //                        self.highlightLetters(box: characterBox)
    //                    }
    //                }
                }
            }
        }
    
      func highlightWord(box: VNTextObservation, translation : String) {
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
                
            let xCord = maxX * sceneView.frame.size.width
            let yCord = (1 - minY) * sceneView.frame.size.height
            let width = (minX - maxX) * sceneView.frame.size.width
            let height = (minY - maxY) * sceneView.frame.size.height
                
            let outline = CATextLayer()
            outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
            outline.borderWidth = 2.0
            outline.backgroundColor = UIColor.darkGray.cgColor
            outline.string = translation
            // fix scaling of text
            outline.font = UIFont(name: "Helvetica", size: height*(1/3))
            outline.shadowOpacity = 0.1
            outline.alignmentMode = CATextLayerAlignmentMode.center
            outline.borderColor = UIColor.blue.cgColor
            
            sceneView.layer.addSublayer(outline)
        }
        
        fileprivate func presentAlert(title: String, message: String) {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
        }
    
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
       // scanFrame()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if case .normal = frame.camera.trackingState {
          
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: CGImagePropertyOrientation(rawValue: 6)!)
                   
            do {
                try imageRequestHandler.perform(self.requests)
            } catch {
                    print(error)
            }
        }
    }
}
